#!/bin/bash

# ファイル指定
txt=~/bin/fand.txt

# 引数取得
hyoka=$(    tr -d , <<<$1 )
last=$(     tr -d , <<<$2 )
kyosyutu=$( tr -d , <<<$3 )

# 引数評価
[[ -z $hyoka ]]    && hyoka=$(    sed -n '1p' $txt ) # 投資した資金の評価額
[[ -z $last ]]     && last=$(     sed -n '2p' $txt ) # 基準価額
[[ -z $kyosyutu ]] && kyosyutu=$( sed -n '3p' $txt ) # 投資額合計

# main 処理
while :
do
    # sleep
    sleep 60

    # 19時台のみ実施
    date '+%H' | grep -q '19' || continue

    # 基準価額取得
    now=$(curl 'http://www.morningstar.co.jp/FundData/SnapShot.do?fnc=2009011606' \
        |& /bin/grep 'span class="fprice"' |& /bin/egrep -o '[0-9,]+' | tr -d ',')
    if [[ -z $last ]];      then last=$now; continue; fi
    if [[ -z $now ]];       then continue; fi
    if [[ $now == "$last" ]]; then continue; fi

    # 騰落率の算出
    p=$( bc -l <<< "$now / $last" )

    # 現在の評価額の算出
    hyoka_now=$( bc <<< "$hyoka * $p" | sed 's/\..*//' )

    # 差額の算出
    kijun_sa=$(( now - last ))
    hyoka_sa=$( LANG=ja_JP.utf-8 ; printf "%'d\n"  $(( hyoka_now - hyoka )) )
    kyosyutsu_sa=$( LANG=ja_JP.utf-8 ; printf "%'d\n"  $(( hyoka_now - kyosyutu )) )
    kyosyutsu_p=$( printf "%.1f" "$(bc -l <<< "$hyoka_now/$kyosyutu * 100")" )

    # 最新の値の保存
    hyoka=$hyoka_now
    last=$now
    cat <<-EOF >$txt
	$hyoka
	$last
	$kyosyutu
	EOF

    # メール送信
    cat <<-EOF | /usr/sbin/sendmail -t
	To: xuhuang.ikin@gmail.com
	Subject: $kijun_sa 円, $hyoka_sa 円, $kyosyutsu_sa 円, $kyosyutsu_p %

	基準価額上下：$kijun_sa 円
	評価額上下  ：$hyoka_sa 円
	通算含み損益：$kyosyutsu_sa 円
	騰落率      ：$kyosyutsu_p %
	EOF
done
