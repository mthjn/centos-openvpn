# centos-openvpn
Install and configure OpenVPN on CentOS 7 with Comodo authoritative DNS

#### How to use it

It generates files for UDP on port 1194. If you use APF or any iptables firewall don't forget to allow this port, it is nonstandard.

```
cd
git clone https://github.com/mthjn/centos-openvpn.git
cd centos-openvpn*
sudo chmod 777 step*
```

* run step 1, do manual modifications as it says
* run step 2, if all works out you're done

Your server and client files are in `/etc/openvpn/easy-rsa/keys`. 

Download to your computer `ca.crt, client.crt, client.key` and put them into some directory.

Create `client.ovpn` in that directory:

```
client
dev tun
proto udp
remote YOUR-SERVER-IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
comp-lzo
verb 3
ca /path/to/ca.crt
cert /path/to/client.crt
key /path/to/client.key
```

Connection:

`sudo openvpn --config client.ovpn`

Test on [ipleak.net](https://ipleak.net)
