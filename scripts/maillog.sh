#!/bin/bash
#!/bin/bash maillog.sh 'origin'
#
LANG=C

set -vx
# 引数チェック
(( $# >= 1 )) || exit 1
set +vx

# 変数
re=$1
qids=()
log="/var/log/mail/maillog"

# reにマッチするqid取得
_qids=$(grep -P "$re" $log | grep "postfix" | grep -Po '(?<=: )\w+(?=:)' | uniq)

# qidの重複を除去
for qid in $_qids; do
    grep -q "$qid" <<<"${qids[@]}" && continue
    qids+=( "$qid" )
done

# 出力
echo ""
for qid in "${qids[@]}"
do
    grep "$qid" $log
    echo ""
done | grep -P --color "^|$re|(from|to)=\S+|status=\w+"
