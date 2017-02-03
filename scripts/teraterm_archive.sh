#!/bin/bash

lastdate=1      # この日数分はアーカイブしない
extension=log
logdir=/cygdrive/c/Users/ikushin/Documents/teraterm_log
[[ ! -d $logdir ]] && exit 1

logs=$(find $logdir/ -maxdepth 1 -mtime +$lastdate -name \*.$extension)
[[ -z $logs ]] && exit 0

dates=( $(egrep -o '20[0-9]{6}' <<<$logs | sort | uniq) ) # ログファイル名から年月日を抽出
for date in ${dates[@]}
do
    year=${date:0:4}; month=${date:4:2}; day=${date:6:2}
    archive_dir=$logdir/$year/$month/$day

    # メイン処理
    [[ -e $archive_dir ]] || mkdir -p $archive_dir
    find $logdir/ -name \*${year}${month}${day}\*.$extension -print0 | xargs -0 mv -t $archive_dir
done
