#!/bin/bash -xue
#
# 一ヶ月アクセスされてないファイルを old へ移動する
#

for d in $(echo */)
do
    mkdir -p $d/old
    find $d -maxdepth 1 -type f -atime +30 | xargs -r /bin/mv -v -t $d/old
done
