#!/usr/bin/env bash
#!/usr/bin/env bash rsync_tmbackup.sh root@localhost:/from/cacti/cacti-export/current/ /to/cacti/cacti-export/
# set -x
# set -v

# LC_ALL を en_US.utf8 にしておく
unset LANG
unset LANGUAGE
LC_ALL=en_US.utf8
export LC_ALL

# スクリプトのディレクトリを保存する
TOP_DIR=$(cd "$(dirname "$0")" && pwd)

APPNAME="${0%.sh}"

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
source $TOP_DIR/$APPNAME.func

# -----------------------------------------------------------------------------
# Make sure everything really stops when CTRL+C is pressed
# -----------------------------------------------------------------------------
trap 'fn_terminate_script' SIGINT

# -----------------------------------------------------------------------------
# Source and destination information
# -----------------------------------------------------------------------------
SSH_DEST_FOLDER=""
SSH_SRC_FOLDER=""
SSH_CMD=""
SSH_DEST_FOLDER_PREFIX=""
SSH_SRC_FOLDER_PREFIX=""
SSH_PORT="22"

SRC_FOLDER=""
DEST_FOLDER=""
EXCLUSION_FILE=""
LOG_DIR="$TOP_DIR/log"
AUTO_DELETE_LOG="0"

AUTO_EXPIRE="1"

RSYNC_FLAGS="-avz"

while :; do
	case $1 in
		-h|-\?|--help)
			fn_display_usage
			exit
			;;
		-p|--port)
			shift
			SSH_PORT=$1
			;;
		--rsync-get-flags)
			shift
			echo $RSYNC_FLAGS
			exit
			;;
		--rsync-set-flags)
			shift
			RSYNC_FLAGS="$1"
			;;
		--log-dir)
			shift
			LOG_DIR="$1"
			AUTO_DELETE_LOG="0"
			;;
		--no-auto-expire)
			AUTO_EXPIRE="0"
			;;
		--)
			shift
			SRC_FOLDER="$1"
			DEST_FOLDER="$2"
			EXCLUSION_FILE="$3"
			break
			;;
		-*)
			fn_log_error "Unknown option: \"$1\""
			fn_log_info ""
			fn_display_usage
			exit 1
			;;
		*)
			SRC_FOLDER="$1"
			DEST_FOLDER="$2"
			EXCLUSION_FILE="$3"
			break
	esac

	shift
done

# 対象ディレクトリの存在を確認する
if [[ -z "$SRC_FOLDER" || -z "$DEST_FOLDER" ]]; then
	fn_display_usage
	exit 1
fi

if [[ ! "$SRC_FOLDER" =~ /$ || ! "$DEST_FOLDER" =~ /$ ]]; then
    fn_log_error "ディレクトリパスの最後に / が無い"
	exit 1
fi

# Strips off last slash from dest. Note that it means the root folder "/"
# will be represented as an empty string "", which is fine
# with the current script (since a "/" is added when needed)
# but still something to keep in mind.
# However, due to this behavior we delay stripping the last slash for
# the source folder until after parsing for ssh usage.

DEST_FOLDER="${DEST_FOLDER%/}"

# SSH経由かどうか判断してパースする
fn_parse_ssh

if [ -n "$SSH_DEST_FOLDER" ]; then
	DEST_FOLDER="$SSH_DEST_FOLDER"
fi

if [ -n "$SSH_SRC_FOLDER" ]; then
	SRC_FOLDER="$SSH_SRC_FOLDER"
fi

# Now strip off last slash from source folder.
SRC_FOLDER="${SRC_FOLDER%/}"

# ディレクトリにシングルクォートが含まれていたら終了
for ARG in "$SRC_FOLDER" "$DEST_FOLDER" "$EXCLUSION_FILE"; do
	if [[ "$ARG" == *"'"* ]]; then
		fn_log_error 'Source and destination directories may not contain single quote characters.'
		exit 1
	fi
done

# -----------------------------------------------------------------------------
# Check that the destination drive is a backup drive
# -----------------------------------------------------------------------------

if [ -z "$(fn_find_backup_marker "$DEST_FOLDER")" ]; then
	fn_log_info "Safety check failed - the destination does not appear to be a backup folder or drive (marker file not found)."
	fn_log_info "If it is indeed a backup folder, you may add the marker file by running the following command:"
	fn_log_info ""
	fn_log_info_cmd "mkdir -p -- \"$DEST_FOLDER\" ; touch \"$(fn_backup_marker_path "$DEST_FOLDER")\""
	fn_log_info ""
	exit 1
fi

# -----------------------------------------------------------------------------
# Setup additional variables
# -----------------------------------------------------------------------------

# Date logic
# NOW=$(date +"%Y-%m-%d-%H%M%S")
NOW=$(date +"%Y-%m-%d")

export IFS=$'\n' # スペースを含むファイル名対応
DEST="$DEST_FOLDER/$NOW"
PREVIOUS_DEST="$(fn_find_backups | head -n 1)"
INPROGRESS_FILE="$DEST_FOLDER/backup.inprogress"
MYPID="$$"

# -----------------------------------------------------------------------------
# Create log folder if it doesn't exist
# -----------------------------------------------------------------------------

if [ ! -d "$LOG_DIR" ]; then
	fn_log_info "Creating log folder in '$LOG_DIR'..."
	mkdir -- "$LOG_DIR"
fi

# -----------------------------------------------------------------------------
# Handle case where a previous backup failed or was interrupted.
# -----------------------------------------------------------------------------

if [ -n "$(fn_find "$INPROGRESS_FILE")" ]; then
	RUNNINGPID="$(fn_run_cmd "cat $INPROGRESS_FILE")"
	if [ "$RUNNINGPID" = "$(pgrep -o -f "$APPNAME")" ]; then
		fn_log_error "Previous backup task is still active - aborting."
		exit 1
	fi

	if [ -n "$PREVIOUS_DEST" ]; then
		# - Last backup is moved to current backup folder so that it can be resumed.
		# - 2nd to last backup becomes last backup.
		fn_log_info "$SSH_DEST_FOLDER_PREFIX$INPROGRESS_FILE already exists - the previous backup failed or was interrupted. Backup will resume from there."
		fn_run_cmd "mv -- $PREVIOUS_DEST $DEST"
		if [ "$(fn_find_backups | wc -l)" -gt 1 ]; then
			PREVIOUS_DEST="$(fn_find_backups | sed -n '2p')"
		else
			PREVIOUS_DEST=""
		fi
		# update PID to current process to avoid multiple concurrent resumes
		fn_run_cmd "echo $MYPID > $INPROGRESS_FILE"
	fi
fi

# Run in a loop to handle the "No space left on device" logic.
while :
do

	# -----------------------------------------------------------------------------
	# Check if we are doing an incremental backup (if previous backup exists).
	# -----------------------------------------------------------------------------

	LINK_DEST_OPTION=""
	if [ -z "$PREVIOUS_DEST" ]; then
		fn_log_info "No previous backup - creating new one."
	else
		# If the path is relative, it needs to be relative to the destination. To keep
		# it simple, just use an absolute path. See http://serverfault.com/a/210058/118679
		PREVIOUS_DEST="$(fn_get_absolute_path "$PREVIOUS_DEST")"
		fn_log_info "Previous backup found - doing incremental backup from $SSH_DEST_FOLDER_PREFIX$PREVIOUS_DEST"
		LINK_DEST_OPTION="--link-dest='$PREVIOUS_DEST'"
	fi

	# -----------------------------------------------------------------------------
	# Create destination folder if it doesn't already exists
	# -----------------------------------------------------------------------------

	if [ -z "$(fn_find "$DEST -type d" 2>/dev/null)" ]; then
		fn_log_info "Creating destination $SSH_DEST_FOLDER_PREFIX$DEST"
		fn_mkdir "$DEST"
	fi

	# -----------------------------------------------------------------------------
	# Purge certain old backups before beginning new backup.
	# -----------------------------------------------------------------------------

	fn_expire_backups

	# -----------------------------------------------------------------------------
	# Start backup
	# -----------------------------------------------------------------------------
	LOG_FILE="$LOG_DIR/$(date +"%Y-%m-%d-%H%M%S").log"

	fn_log_info "Starting backup..."
	fn_log_info "From: $SSH_SRC_FOLDER_PREFIX$SRC_FOLDER/"
	fn_log_info "To:   $SSH_DEST_FOLDER_PREFIX$DEST/"

	CMD="rsync"
	if [ -n "$SSH_CMD" ]; then
		CMD="$CMD  -e 'ssh -p $SSH_PORT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"
	fi
	CMD="$CMD $RSYNC_FLAGS"
	CMD="$CMD --log-file '$LOG_FILE'"
	if [ -n "$EXCLUSION_FILE" ]; then
		# We've already checked that $EXCLUSION_FILE doesn't contain a single quote
		CMD="$CMD --exclude-from '$EXCLUSION_FILE'"
	fi
	CMD="$CMD $LINK_DEST_OPTION"
	CMD="$CMD -- '$SSH_SRC_FOLDER_PREFIX$SRC_FOLDER/' '$SSH_DEST_FOLDER_PREFIX$DEST/'"

	fn_log_info "Running command:"
	fn_log_info "$CMD"

	fn_run_cmd "echo $MYPID > $INPROGRESS_FILE"
	eval $CMD

	# -----------------------------------------------------------------------------
	# Check if we ran out of space
	# -----------------------------------------------------------------------------

	NO_SPACE_LEFT="$(grep "No space left on device (28)\|Result too large (34)" "$LOG_FILE")"

	if [ -n "$NO_SPACE_LEFT" ]; then

		if [[ $AUTO_EXPIRE == "0" ]]; then
			fn_log_error "No space left on device, and automatic purging of old backups is disabled."
			exit 1
		fi

		fn_log_warn "No space left on device - removing oldest backup and resuming."

		if [[ "$(fn_find_backups | wc -l)" -lt "2" ]]; then
			fn_log_error "No space left on device, and no old backup to delete."
			exit 1
		fi

		fn_expire_backup "$(fn_find_backups | tail -n 1)"

		# Resume backup
		continue
	fi

	# -----------------------------------------------------------------------------
	# Check whether rsync reported any errors
	# -----------------------------------------------------------------------------

	EXIT_CODE="1"
	if grep -q "rsync error:" "$LOG_FILE"; then
		fn_log_error "Rsync reported an error. Run this command for more details: grep -E 'rsync:|rsync error:' '$LOG_FILE'"
	elif grep -q "rsync:" "$LOG_FILE"; then
		fn_log_warn "Rsync reported a warning. Run this command for more details: grep -E 'rsync:|rsync error:' '$LOG_FILE'"
	else
		fn_log_info "Backup completed without errors."
		if [[ $AUTO_DELETE_LOG == "1" ]]; then
			rm -f -- "$LOG_FILE"
		fi
		EXIT_CODE="0"
	fi

	# -----------------------------------------------------------------------------
	# Add symlink to last backup
	# -----------------------------------------------------------------------------

	fn_rm_file "$DEST_FOLDER/current"
	fn_ln "$(basename -- "$DEST")" "$DEST_FOLDER/current"

	fn_rm_file "$INPROGRESS_FILE"

	exit $EXIT_CODE
done
