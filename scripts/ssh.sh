#!/bin/bash
# set -x

TOP_DIR=$(cd $(dirname "$0") && pwd)
lst="$TOP_DIR/ssh.lst"

node=$(basename $0)
IFS=, read -r node ip user pass <<<"$(grep -w "$node" $lst)"
[[ -n $pass ]] && echo $pass
[[ -z $user ]] && user=root

set -x
ssh -l$user $@ $ip
