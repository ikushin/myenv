#!/bin/bash
# set -x

# usage
function usage()
{
    echo "Usage: ${0##*/} IP"
    exit $1
}

ip=$1
[[ $ip ]] || usage

# vars
private=$ip.key
cert=$ip.crt

# Distinguished Name (DN)
ct="US"
st="California"
ln=""
on="Super Micro Computer"
ou="Software"
cn=$ip

# Step 1: Generate a Private Key
openssl genrsa -passout pass:"PASS" -out $private 2048

# Step 2: Generate a CSR
openssl req -batch -new -key $private -out $cert -passin pass:"PASS" \
        -subj "/C=$ct/ST=$st/L=$ln/O=$on/OU=$ou/CN=$cn"

# Step 3: Remove Passphrase from Key
/bin/mv $private $private.org
openssl rsa -in $private.org -out $private

# Step 4: Generating a Self-Signed Certificate
openssl x509 -req -days 3650 -in $cert -signkey $private -out $cert

# Step 5: Check and clean
out=$(openssl x509 -in  $cert -text -noout)
{
    echo =====
    egrep -A1 "Serial Number:" <<<$out | tr -d '\n'
    echo
    egrep 'Issuer:|Subject:' <<<$out
    echo =====
} | sed -r 's/ +/ /g'

/bin/rm $private.org

exit 0
