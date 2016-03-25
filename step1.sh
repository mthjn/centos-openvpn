#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Do it as root" 1>&2
  exit 1
fi

echo "Preparatory tasks ... "

yum install epel-release
yum install openvpn easy-rsa -y
cp /usr/share/doc/openvpn-*/sample/sample-config-files/server.conf /etc/openvpn

echo 'Manually edit ”/etc/openvpn/server.conf” ====> uncomment:'
echo 'push "redirect-gateway def1 bypass-dhcp"'
# Comodo DNS: 8.26.56.26, 8.20.247.20  - I dont like google
echo 'push "dhcp-option DNS 8.26.56.26"'
echo 'push "dhcp-option DNS 8.20.247.20"'
echo 'user nobody; group nobody'

