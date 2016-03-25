#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Do it as root" 1>&2
  exit 1
fi

mkdir -p /etc/openvpn/easy-rsa/keys
cp -rf /usr/share/easy-rsa/2.0/* /etc/openvpn/easy-rsa
cp /etc/openvpn/easy-rsa/openssl-1.0.0.cnf /etc/openvpn/easy-rsa/openssl.cnf

echo "Manually edit ”/etc/openvpn/easy-rsa/vars”:"
echo "Set all ”KEY_” values."
echo "KEY_NAME should be ”server”"
echo "Setting KEY_CN not necessary."
