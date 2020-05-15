#!/bin/bash gen_macro.sh
# set -e
# set -u
# set -x

export PATH="/bin:/usr/bin"
export LANG=C
TOP_DIR=$(cd $(dirname "$0") && pwd)
oIFS=$IFS
q='\x22'

# 変数
# ------------
ips=()
hosts=()
tsv="$TOP_DIR/ip.tsv"

# main
# ----
IFS=$'\n'
servers=( $(grep -Pi 'RHEL|CentOS' $tsv | grep -Pv 'STE?P') )
IFS=$oIFS

for i in ${!servers[@]}
do
    IFS=$'\t' read -ra server <<<"${servers[$i]}"
    ip=${server[@]:0:4}; ip=${ip// /}
    hostname=${server[4]}
    alias=${server[6]}

    hosts+=("HOSTNM[$i] = ${q}$hostname($alias)${q}")
    ips+=("HOSTIP[$i] = ${q}$ip${q}")
done

cat <<EOF

;; ホスト名
strdim HOSTNM ${#servers[@]}
$(printf "%b\n" "${hosts[@]}")

;; IP
strdim HOSTIP ${#servers[@]}
$(printf "%b\n" "${ips[@]}")
EOF
