#!/bin/bash
set -eu
set -x

PASSFILE="$HOME/local/bin/.sshpass"
[[ -d "$HOME/local/bin" ]] || exit

echo 'password' >$PASSFILE
ssh="sshpass -f $PASSFILE ssh -lroot \$@"
ssh_d="$HOME/local/bin"
hosts=(
    "10.0.0.1,host1,alias1"
    "10.0.0.2,host2,alias2"
    "10.0.0.3,host3"
)

mkdir -p $ssh_d
for f in ${hosts[*]}
do
    ip=$(cut -d, -f1 <<<$f)
    host=$(cut -d, -f2 <<<$f)
    alias=$(cut -d, -f3 <<<$f)

    for h in $host $alias
    do
        tee $ssh_d/$h <<<"$ssh $ip"
        chmod +x $ssh_d/$h
    done
done
