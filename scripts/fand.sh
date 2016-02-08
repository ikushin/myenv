#!/bin/bash

hyoka=$(    tr -d , <<<$1 )
last=$(     tr -d , <<<$2 )
kyosyutu=$( tr -d , <<<$3 )

txt=~/bin/fand.txt
[[ -z $hyoka ]]    && hyoka=$(    sed -n '1p' $txt ) # 投資した資金の評価額
[[ -z $last ]]     && last=$(     sed -n '2p' $txt ) # 基準価額
[[ -z $kyosyutu ]] && kyosyutu=$( sed -n '3p' $txt ) # 投資額合計

while :
do
    sleep 60
    date '+%H' | grep -q '19' || continue

    now=$(curl 'http://www.morningstar.co.jp/FundData/SnapShot.do?fnc=2009011606' \
        |& /bin/grep 'span class="fprice"' \
        |& /bin/egrep -o '[0-9,]+' \
        |  tr -d ',')
    if [[ -z $last ]]; then last=$now; continue; fi
    if [[ -z $now ]];  then continue; fi

    if [[ $now != $last ]]; then
        p=$( bc -l <<< "$now / $last" )
        hyoka_now=$( bc <<< "$hyoka * $p" | sed 's/\..*//' )

        kijun_sa=$(( $now - $last ))
        hyoka_sa=$( LANG=ja_JP.utf-8 ; printf "%'d\n"  $(( $hyoka_now - $hyoka )) )
        kyosyutsu_sa=$( LANG=ja_JP.utf-8 ; printf "%'d\n"  $(( $hyoka_now - $kyosyutu )) )

        hyoka=$hyoka_now
        last=$now

        cat <<-EOF >$txt
	$hyoka
	$last
	$kyosyutu
	EOF

        cat <<-EOF | /usr/sbin/sendmail -t
	To: xuhuang.ikin@gmail.com
	Subject: $kijun_sa 円, $hyoka_sa, $kyosyutsu_sa 円

	基準価額：$kijun_sa 円
	評価額  ：$hyoka_sa
	含み損益：$kyosyutsu_sa
	EOF
    fi
done
