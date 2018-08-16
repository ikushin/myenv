#!/bin/bash
#!/bin/bash gen_self_crt.sh 127.0.0.1
# set -x
# set -u
# set -e

# LC_ALL を en_US.utf8 にしておく
unset LANG
unset LANGUAGE
LC_ALL=en_US.utf8
export LC_ALL

# スクリプトのディレクトリを保存する
TOP_DIR=$(cd $(dirname "$0") && pwd)

# usage
function usage()
{
    echo "Usage: ${0##*/} IP"
    exit $1
}

ip=$1
[[ $ip ]] || usage

# vars
outdir=$TOP_DIR/out
private=$outdir/$ip.key
cert=$outdir/$ip.crt
log=$outdir/$ip.log

# Distinguished Name (DN)
C="US"                          # Country (国名)
ST="California"                 # State (都道府県名)
L=""                            # Locality (市区町村名)
O="Super Micro Computer"        # Organizational Name (組織名)
OU="Software"                   # Organizational Unit (部門名)
CN=$ip                          # Common Name (コモンネーム)

# Step 0: mkdir
mkdir -p $outdir

# Step 1: Generate a Private Key
openssl genrsa -passout pass:"PASS" -out $private 2048

# Step 2: Generate a CSR
openssl req -batch -new -key $private -out $cert -passin pass:"PASS" \
        -subj "/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$CN"

# Step 3: Remove Passphrase from Key
/bin/mv $private $private.org
openssl rsa -in $private.org -out $private

# Step 4: Generating a Self-Signed Certificate
openssl x509 -req -days 3650 -in $cert -signkey $private -out $cert

# Step 5: Check and clean
out=$(openssl x509 -in  $cert -text -noout)
{
    egrep -A1 "Serial Number:" <<<"$out" | tr -d '\n'
    echo
    egrep 'Issuer:|Subject:' <<<"$out"
} | sed -r 's/ +/ /g' &>$log

/bin/rm $private.org

exit 0
