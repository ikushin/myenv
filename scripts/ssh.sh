#!/bin/bash
# set -x

TOP_DIR=$(cd $(dirname "$0") && pwd)
lst="$TOP_DIR/ssh.lst"

node=$(basename $0)
ip=$(grep -w "$node" $lst | cut -d, -f2)

set -x
ssh -lroot $@ $ip
