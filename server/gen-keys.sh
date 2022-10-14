#!/bin/sh
# Copyright © 2014 Steffan Karger <steffan@karger.me>
set -eu
command -v openssl >/dev/null 2>&1 || { echo >&2 "Unable to find openssl. Please make sure openssl is installed and in your path."; exit 1; }
if [ ! -f openssl.cnf ]
then
echo "Please run this script from the sample directory"
exit 1
fi
# Generate static key for tls-auth (or static key mode)
openvpn --genkey --secret ta.key
# Create required directories and files
mkdir -p sample-ca
rm -f sample-ca/index.txt
touch sample-ca/index.txt
echo "01" > sample-ca/serial
# Generate CA key and cert
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
-extensions easyrsa_ca -keyout sample-ca/ca.key -out sample-ca/ca.crt \
-subj "/C=VN/ST=SAIGON/L=SAIGON/O=OpenVPN-TEST/emailAddress=vpn@test.net" \
-config openssl.cnf
# Create server key and cert
openssl req -new -nodes -config openssl.cnf -extensions server \
-keyout sample-ca/server.key -out sample-ca/server.csr \
-subj "/C=VN/ST=SAIGON/O=OpenVPN-TEST/CN=VPN-Server/emailAddress=vpn@test.net"
openssl ca -batch -config openssl.cnf -extensions server \
-out sample-ca/server.crt -in sample-ca/server.csr
# Generate DH parameters
openssl dhparam -out dh2048.pem 2048
cp sample-ca/server.crt /etc/openvpn/
cp sample-ca/server.key /etc/openvpn/
cp sample-ca/ca.crt /etc/openvpn/
cp dh2048.pem /etc/openvpn/
