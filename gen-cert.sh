#!/bin/bash
 
#Required
domain=$1
commonname=$domain
country=US
state=California
locality="San Francisco"
organization=Reemitch-LLC
organizationalunit="Web Encryption Services"
email=reemitch@reemitch.link

#Optional
password=$(some_password)
 
if [ -z "$domain" ]
then
    echo "Argument not present."
    echo "Useage $0 [common name]"
 
    exit 99
fi
 
echo "Generating key request for $domain"
 
#Generate a key
#openssl genrsa -des3 -passout pass:$password -out $domain.key 2048 -noout
openssl genrsa -out /root/interm/private/$domain.key 2048

#Remove passphrase from the key. Comment the line out to keep the passphrase
#echo "Removing passphrase from key"
#openssl rsa -in $domain.key -passin pass:$password -out $domain.key
 
#Create the request

echo "Creating CSR"

#openssl req -config /root/interm/openssl.cnf -new -key $domain.key -out $domain.csr -passin pass:$password \
#-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
openssl req -config /root/interm/openssl.cnf -new -key /set/private/key/folder/$domain.key -sha256 -out $domain.csr -passin pass:$password \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

openssl ca -config /root/interm/openssl.cnf -extensions server_cert -days 375 -notext -md sha256 \
   -in $domain.csr -out ./$domain.crt -passin pass:$password

openssl pkcs12 -export -out ./$domain.p12 -in ./$domain.crt -inkey /set/private/key/folder/$domain.key -passin pass:root -passout pass:root

mv ./$domain.csr /set/csr/folder/csr/

echo "---------------------------"
echo "----Below is your pkcs12---"
echo "---------------------------"
echo
cat $domain.p12
 
echo
echo "---------------------------"
echo "-----Below is your Key-----"
echo "---------------------------"
echo
cat private/$domain.key

echo
echo "---------------------------"
echo "--And your Certificate-----"
echo "---------------------------"
echo
cat $domain.crt
exit 0

