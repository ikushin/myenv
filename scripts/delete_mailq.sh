#!/bin/bash
#
# 概要:
#   閾値を超えた場合、mailq 内の任意の FROM/TO 宛のメールを削除する。
#   閾値はスクリプトの引数で指定する。引数がない場合の閾値は0である。
#

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

# 引数チェック
if [[ $# > 0 ]]; then
    if ! egrep -q '^[0-9]+$' <<<$1; then
        message "error: '$1' is not numerical value."
        exit 1
    fi
    arg=$1
fi

# 閾値の設定
threshold=${arg:=0}

# 削除対象の FROM/TO を正規表現で指定する
from="^MAILER-DAEMON$"
to="^.*@example.com$"

# mailq の数
nr_mailq=$(mailq 2>/dev/null | egrep -c "^[[:alnum:]]{11}")

# nr_mailq が数値であるかチェック
if ! egrep -q '^[0-9]+$' <<<$nr_mailq; then
    message "error: '$nr_mailq' is not numerical value."
    exit 1
fi

# 閾値以下ならスクリプト終了
if [[ $nr_mailq -le $threshold ]]; then
    tty -s && echo "mailq($nr_mailq) <= threshold($threshold), exit."
    exit 0
fi

# mailq の削除
message "start:"
output=$( mailq | tail -n +2 | \
             /bin/grep -v '^ *(' | \
             awk "BEGIN { RS = \"\" } { if( \$7 ~ \"$from\" && \$8 ~ \"$to\" && \$9 == \"\") print \$1 }" | \
             tr -d '*!' | \
             postsuper -d - 2>&1 ); rc=$?

# 終了メッセージ生成
if egrep -q "Deleted" <<<$output; then
    return_message=$( egrep -o 'postsuper: Deleted:.*messages?' <<<$output )
else
    return_message=$output
fi

# 終了処理
[[ $rc == 0 ]] && end="end" || end="error"
message "$end: $return_message"
