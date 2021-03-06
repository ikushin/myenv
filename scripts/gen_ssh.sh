#!/bin/bash
set -e
set -u
set -x

# 変更する変数
# ------------
user="root"
pass='password'
hosts=(
    "10.0.0.1,host1,alias1"
    "10.0.0.2,host2,alias2"
    "10.0.0.3,host3"
)

# 変更しない変数
# ------------
ssh_d="$HOME/local/bin"
pass_file="$HOME/local/bin/.sshpass"
ssh="sshpass -f $pass_file ssh -l$user \$@"

# main
# ----
mkdir -p $ssh_d
echo $pass >$pass_file
for f in ${hosts[*]}
do
    IFS=',' read -r ip host alias <<<"$f"

    for h in $host $alias
    do
        tee $ssh_d/$h <<<"$ssh $ip"
        chmod +x $ssh_d/$h
    done
done
