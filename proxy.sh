#!/bin/bash

proxy=http://proxy:8080
_no=( localhost 127.0.0.1 )
_no+=( $(/sbin/ip -4 -o addr | grep -vw lo | grep -Po '(?<=inet )\S+(?=/)') )

oIFS=$IFS; IFS=,
no="${_no[*]}"
IFS=$oIFS

cat <<EOF >$HOME/.proxy
# proxy
proxy=$proxy
export {HTTP{,S}_PROXY,http{,s}_proxy}=\$proxy

# no_proxy
export no_proxy=$no

EOF
