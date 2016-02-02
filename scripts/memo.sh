
# Prints help message
usage()
{
    /bin/cat >&2 <<- EOF_USAGE

	Usage: $0 -f instructions_file [-a archive_file]

	Options:
	        -a - Archive file on which actions will be performed, as opposed to
	             current directory
	        -f - The instructions file to check against.
	EOF_USAGE
    #exit 2
}

[ "$1" = "--help" ] && usage

[ "$#" = 0 ] && usage

IFS=$'\n'

