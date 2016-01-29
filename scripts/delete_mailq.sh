#!/bin/bash
#
# 概要:
#   mailq 内の任意の FROM/TO 宛のメールを削除する
#

# 削除対象の FROM/TO を正規表現で指定する
from="^MAILER-DAEMON$"
to="^.*@example.com$"

# シェル関数
function message()
{
    logger -t "$0" $*
    tty -s && echo $*  # tty が存在すれば message を出力する
}

# 多重起動チェック
if [ $$ -ne $(pgrep -fo "$0") ]; then
    message "error: Cannot run multiple instance."
    exit 1
fi

# mailq の削除
message "start:"
output=$( mailq | tail -n +2 | \
             /bin/grep -v '^ *(' | \
             awk "BEGIN { RS = \"\" } { if( \$7 ~ \"$from\" && \$8 ~ \"$to\" && \$9 == \"\") print \$1 }" | \
             tr -d '*!' | \
             postsuper -d - 2>&1 ); rc=$?

# 終了メッセージ生成
if egrep -q "Deleted" <<<"$output"; then
    return_message=$( egrep -o 'postsuper: Deleted:.*messages?' <<<"$output" )
else
    return_message=$output
fi

# 終了処理
[[ $rc == 0 ]] && end="end" || end="error"
message "$end: $return_message"
