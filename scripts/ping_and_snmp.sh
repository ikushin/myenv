#!/bin/bash
#!/bin/bash ./precheck_add_cisco.sh *.tsv
# set -e
# set -u
# set -v
# set -x
LANG=C

file=$1
[[ -f $file ]] || exit 1

list=$(grep -Pv '^#' $file)

while read -r ip node
do

    # pingチェック
    ping -c1 -W1 $ip &>/dev/null; rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "$node: PING -> NG" | /bin/grep --color '^.*$'
        continue
    fi
    echo "$node: PING -> OK"

    # snmpチェック
    snmpwalk -t 0.3 -v2c -c sol-watch $ip sysDescr &>/dev/null; rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "$node: SNMP -> NG" | /bin/grep --color '^.*$'
        continue
    fi
    echo "$node: SNMP -> OK"

done <<<"$list"
