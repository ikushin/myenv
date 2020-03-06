#!/bin/bash
#!/bin/bash -x tmp_archive.sh
#set -x
set -e
set -u
LANG=C

# スクリプトのディレクトリを保存する
TOP_DIR=$(cd $(dirname "$0") && pwd)

lastdate=7      # この日数分はアーカイブしない
logdir="/cygdrive/c/Users/ikushin/Desktop/tmp"
find="find $logdir/ -daystart -maxdepth 1"

for (( i=1,j=2 ;; i++,j++ )); do

    end=$(date   '+%F' -d "$i weeks ago monday")
    start=$(date '+%F' -d "$j weeks ago monday")

    # アーカイブ対象が無くなったら終了
    files=$($find -atime +$lastdate -not -name "202?-??-??")
    [[ -z $files ]] && break

    mkdir -p $logdir/$start
    $find -newerat $start ! -newerat $end -and -atime +$lastdate -not -name "202?-??-??" -print0 |
        xargs -r -0 /bin/mv -t $logdir/$start
done

# 整理
rmdir --ignore-fail-on-non-empty $logdir/*/

exit 0
