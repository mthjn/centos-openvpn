#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Do it as root" 1>&2
  exit 1
fi

echo "Preparatory tasks ... "

yum install epel-release
# => yum whatprovides netstat && yum whatprovides ifconfig
yum install net-tools -y 
yum install openvpn easy-rsa -y
cp /usr/share/doc/openvpn-*/sample/sample-config-files/server.conf /etc/openvpn

# => check if TUN/TAP enabled
if [ ! -c /dev/net/tun ] ; then
  rm -f /dev/net/tun
  mkdir -p /dev/net
  mknod /dev/net/tun c 10 200
  chmod 600 /dev/net/tun
  if [ "$?" -ne 0 ] ; then
    echo "Error creating tun device file"
    exit 1
  fi
fi

case `cat /dev/net/tun 2>&1` in
*"File descriptor in bad state" )
  echo "TUN device is fine." ;;
* )
  echo "TUN device is disabled? ====> Create tun device: ”ip tuntap add tun0 mode tun”." ;;
esac

echo 'Manually edit ”/etc/openvpn/server.conf” ====> uncomment:'
echo 'push "redirect-gateway def1 bypass-dhcp"'
# Comodo DNS: 8.26.56.26, 8.20.247.20  - I dont like google
echo 'push "dhcp-option DNS 8.26.56.26"'
echo 'push "dhcp-option DNS 8.20.247.20"'
echo 'user nobody; group nobody'

