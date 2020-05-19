#!/bin/bash

lastdate=0      # この日数分はアーカイブしない
extension="reg"
logdir="/cygdrive/c/Users/ikushin/Documents/dsp316/backup"
[[ ! -d $logdir ]] && exit 1

logs=$(find $logdir/ -maxdepth 1 -mtime +$lastdate -name \*.$extension)
[[ -z $logs ]] && exit 0

dates=( $(/bin/grep -Po '20\d{2}_\d{4}' <<<$logs | sort | uniq) ) # ログファイル名から年月日を抽出
for date in "${dates[@]}"
do
    year=${date:0:4}; month=${date:5:2};
    archive_dir=$logdir/$year/$month

    # メイン処理
    [[ -e $archive_dir ]] || mkdir -p $archive_dir
    find $logdir/ -name \*${year}_${month}\*.$extension -print0 | xargs -0 mv -t $archive_dir
done
