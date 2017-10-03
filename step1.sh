#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Do it as root" 1>&2
  exit 1
fi

function pause(){
   read -p "$*"
}

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
  echo "TUN device is fine." 
  ;;
* )
  echo "TUN device is disabled?"
  echo "Create tun device: ”ip tuntap add tun0 mode tun” ... " 
  ip tuntap add tun0 mode tun
  ;;
esac

pause 'Fine [Enter]'

echo 'Editing ”/etc/openvpn/server.conf”'
# Comodo DNS: 8.26.56.26, 8.20.247.20  - I dont like google
>/etc/openvpn/server.conf cat <<EOF
#
# OpenVPN server config
#
port 	                  1194 # open up this port on your firewall.
proto 	                udp
dev 	                  tun
ca 	                    ca.crt
cert 	                  server.crt
key 	                  server.key
dh 	                    dh2048.pem
server 	                10.8.0.0 255.255.255.0
ifconfig-pool-persist 	ipp.txt
push 			              "redirect-gateway def1 bypass-dhcp"
push 			              "dhcp-option DNS 8.26.56.26"
push 			              "dhcp-option DNS 8.20.247.20"
duplicate-cn
keepalive 		          10 120
comp-lzo
user 	                  nobody
group 	                nobody
persist-key
persist-tun
status 	                openvpn-status.log
verb 	                  9
mute 	                  20
EOF

echo "Check file: /etc/openvpn/server.conf"
cat /etc/openvpn/server.conf
pause 'Alright [Enter]'

echo "Creating directory for keys ..."
mkdir -p /etc/openvpn/easy-rsa/keys
cp -rf /usr/share/easy-rsa/2.0/* /etc/openvpn/easy-rsa
cp /etc/openvpn/easy-rsa/openssl-1.0.0.cnf /etc/openvpn/easy-rsa/openssl.cnf

echo "=========================================================================="
echo "You should manually fill your information in ”/etc/openvpn/easy-rsa/vars”:"
echo " = Set all ”KEY_” values."
echo " = KEY_NAME should be ”server”"
echo " = Pre-setting KEY_CN not necessary."
echo "You can use a (sub)domain that resolves to your server or just IP. Each user needs unique KEY_CN."
echo "=========================================================================="

pause 'Alright interrupt script now. [Enter]'
