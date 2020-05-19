#!/bin/bash
#!/bin/bash ./Archive.sh -v "/cygdrive/z/tmp"
#!/bin/bash ./Archive.sh -v "/cygdrive/z/share"
#!/bin/bash ./Archive.sh -v "/cygdrive/c/Users/ikushin/Downloads"
#!/bin/bash ./Archive.sh -v "/cygdrive/c/Users/ikushin/Desktop/tmp"
# set -x
# set -e
# set -u
LANG=C

# OPT
while :
do
    case $1 in
        -v|--verbose)
            verbose=$((verbose + 1))
            ;;
        *)
            break
            ;;
    esac
    shift
done

[[ $verbose -ge 1 ]] && VERBOSE="true"
[[ $VERBOSE ]] && set -x

# 引数チェック
dir=$1
[[ -d $dir ]] || exit 1

# 変数
lastdate=7      # この日数分はアーカイブしない
find="find $dir/ -daystart -maxdepth 1"

# main
for (( i=1,j=2; ; i++,j++ )); do

    end=$(date   '+%F' -d "$i weeks ago monday")
    start=$(date '+%F' -d "$j weeks ago monday")

    # アーカイブ対象が無くなったら終了
    files=$($find -atime +$lastdate -not -name "202?-??-??")

    set +x
    [[ -z $files ]] && break
    [[ $VERBOSE ]] && set -x

    mkdir -p "$dir/$start"
    $find -newerat "$start" ! -newerat "$end" -and -atime +$lastdate -not -name "202?-??-??" -print0 |
        xargs -r -0 /bin/mv -t "$dir/$start"
done

# 整理
rmdir --ignore-fail-on-non-empty "$dir"/*/

exit 0
