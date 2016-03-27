#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Do it as root" 1>&2
  exit 1
fi

function pause(){
   read -p "$*"
}

echo "Setting vars and creating server certificates..."
cd /etc/openvpn/easy-rsa
source ./vars

echo "Cleaning all..."
pause 'Fine [Enter]'
./clean-all

echo "Building server-side..."
pause 'Fine [Enter]'

./build-ca
./build-key-server server

echo "Start Diffie Helmann ..."
pause 'Fine [Enter]'

./build-dh
cd /etc/openvpn/easy-rsa/keys
cp dh2048.pem ca.crt server.crt server.key /etc/openvpn

cd /etc/openvpn/easy-rsa

echo "Build single client files ... "
pause 'Fine [Enter]'
./build-key client

echo "Routing: Disabling firewalld and using iptables instead ..."
pause 'Fine [Enter]'

yum install iptables-services -y
systemctl mask firewalld
systemctl enable iptables
systemctl stop firewalld
systemctl start iptables
iptables --flush

#internal routing: on OpenVZ the interface is venet0 not eth0
echo "Internal routing: this uses interface eth0. If you have venet0 (check by running ifconfig), edit it in /etc/sysconfig/iptables."
pause 'Fine [Enter]'

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

echo "Restarting network, enabling openvpn service..."
pause 'Fine [Enter]'

systemctl restart network.service
systemctl -f enable openvpn@server.service
systemctl start openvpn@server.service

echo "Grepping netstat to see if openvpn is there ... "
netstat -taupen | grep "openvpn"
pause 'Fine [Enter]'

echo "Конец фильма."
