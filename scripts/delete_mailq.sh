#!/bin/bash -x delete_mailq.sh
#!/bin/bash
#
# 概要:
#   閾値を超えた場合、mailq 内の from = MAILER-DAEMON かつ 指定した TO 宛のメールを削除する。
#

# 多重起動チェック
#if [ $$ -ne $(pgrep -fo "$0") ]; then
#    logger -t "$0" "error: Cannot run multiple instance"
#    exit 1
#fi

# 引数チェック
if [[ $# > 0 ]]; then
    if ! egrep -q '^[0-9]+$' <<<$1; then
        logger -t "$0" "error: '$1' is not numerical value"
        exit 1
    fi
    arg=$1
fi

# この閾値以上で mailq を削除する
threshold=${arg:=0}

# 削除対象の TO を正規表現で指定する
from="MAILER-DAEMON"
to="@example.com$"

# mailq の数
nr_mailq=$(mailq 2>/dev/null | egrep -c "^[[:alnum:]]{11}")

# nr_mailq が数値であるかチェック
if ! egrep -q '^[0-9]+$' <<<$nr_mailq
then
    logger -t "$0" "error: '$nr_mailq' is not numerical value"
    exit 1
fi

# 閾値を下回っていたらスクリプト終了
[[ $nr_mailq < $threshold ]] && exit 1

# main 処理
logger -t "$0" "start"
output=$( mailq | tail -n +2 | \
             /bin/grep -v '^ *(' | \
             awk "BEGIN { RS = \"\" } { if( \$7 == $from && \$8 ~ $to && \$9 == \"\") print $1 }" | \
             tr -d '*!' | \
             sudo postsuper -d - 2>&1 ); rc=$?

# 終了メッセージ生成
if egrep "Deleted" <<<$output; then
    return_message=$( egrep -o 'postsuper: Deleted:.*messages' <<<$output )
else
    return_message=$output
fi

# 終了処理
[[ $rc == 0 ]] && end="end" || end="error"
logger -t "$0" "$end: $return_message"
