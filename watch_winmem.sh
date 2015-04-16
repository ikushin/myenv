#!/bin/bash
#
# 1. PATHにC:\cygwin\binを追加する
# 2. cmdで以下が成功することを確認する
#    bash C:\cygwin\home\ikushin\.myenv\watch_winmem.sh
# 3. dspiceで定期実行
#

threshold=800

mem=$(/cygdrive/c/Windows/System32/typeperf "\Memory\Available Bytes" -sc 1 | \
    grep '^.[0-9][0-9]/' | cut -d, -f2 | tr -d \" | egrep -o '^[0-9]+')
hmem=$(($mem/1048576))


if [[ $hmem -lt $threshold || $# -gt 0 ]];
then
    /cygdrive/c/Windows/System32/msg console /server:localhost "Available Memory: $hmem MB"
fi
