**INSTALL AND CONFIGURE DNS SERVER ON OL9.5**

> *BIND (Berkeley Internet Name Domain) is a DNS (Domain Name System) server software essential to the functioning of the Internet. Its main use is to translate domain names (such as "google.com") into IP addresses (such as "172.217.160.142"), which are the numeric identifiers that computers use to communicate with each other..*

![bind9 logo.](https://github.com/danilo01arrudal/Exated/blob/main/Bind/images/bind.png)

###### BUILD MACHINE

    [root@localhost ~]# virt-install --virt-type kvm --name ol9bind --memory 2048 --vcpus 1 --os-variant ol9.7 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U7-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9d.qcow2,size=10

###### REMOVE DNSMASQ AND AVAHI-DAEMON
    [root@localhost ~]# systemctl stop dnsmasq
    [root@localhost ~]# systemctl stop avahi-daemon
    [root@localhost ~]# systemctl disable dnsmasq
    [root@localhost ~]# systemctl disable avahi-daemon
    [root@localhost ~]# yum remove -y dnsmasq

###### DISABLE SELINUX AND FIREWALLD
    [root@localhost ~]# sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config && setenforce 0

###### CONFIGURE STATIC NETWORK
    
    [root@localhost ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    lo      loopback  connected (externally)  lo   

    [root@localhost ~]# nmcli connection show 
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  82e45657-ca14-380d-adfc-ac71a5aa7281  ethernet  enp1s0 
    lo      c30f3777-2d34-40f9-9fdb-da73383b9848  loopback  lo  

    [root@localhost ~]# nmcli con modify 'enp1s0' iframe enp1s0 ipv4.method manual ipv4.addresses 192.168.18.201/24 gw4 192.168.18.1
    [root@localhost ~]# nmcli con modify 'enp1s0' ipv4.dns 8.8.8.8
    [root@localhost ~]# nmcli con down 'enp1s0'
    [root@localhost ~]# nmcli con up 'enp1s0'

    [root@localhost ~]# ip addr show enp1s0
    2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:bc:5a:a4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.201/24 brd 192.168.18.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever
    inet6 2804:248:f65e:2800:5054:ff:febc:5aa4/64 scope global dynamic noprefixroute 
       valid_lft 86197sec preferred_lft 86197sec
    inet6 fe80::5054:ff:febc:5aa4/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever

    [root@localhost ~]# ip route show
    default via 192.168.18.1 dev enp1s0 proto static metric 100 
    192.168.18.0/24 dev enp1s0 proto kernel scope link src 192.168.18.101 metric 100 

###### CONFIGURE HOSTNAME
    [root@localhost ~]# hostnamectl 
    [root@localhost ~]# hostnamectl set-hostname ol9dns
    [root@localhost ~]# hostnamectl --static 

###### CONFIGURE /ETC/HOSTS FILE

    [root@ol9dns ~]# vi /etc/hosts
                    127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
                    ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
                    192.168.18.201	ol9dns

###### INSTALL PACKAGE DNS BIND

    [root@ol9dns ~]# yum install bind bind-utils -y

###### CREATE NAMED FILE
    
    [root@ol9dns ~]# mv /etc/named.conf /etc/named.conf.bkp
    [root@ol9dns ~]# vi /etc/named.conf
                options {
                        directory "/var/named";
                };

                zone "appsdba.info" IN {
                        type master;
                        file "data/appsdba.info.zone";
                };

                zone "18.168.192.in-addr.arpa" IN {
                        type master;
                        file "data/192.168.18.zone";
                };                

###### CREATE APPSDBA.INFO.ZONE FOR RESOLUTION UNDER /VAR/NAMED/DATA/

    [root@ol9dns ~]# vi /var/named/data/appsdba.info.zone 
                $ttl 38400
                @       IN      SOA     ol9dns.appsdba.info.    root.appsdba.info. (
                        2020032701      ;
                        3600    ;
                        3600    ;
                        604800  ;
                        86400 ) ;

                @       IN      NS      ol9dns.appsdba.info.
                ol9dns          IN      A       192.168.18.201
                ol9n1           IN      A       192.168.18.121
                ol9n2           IN      A       192.168.18.122
                ol9n1-vip	    IN	    A	    192.168.18.151
                ol9n2-vip	    IN	    A	    192.168.18.152
                ol9n-scan       IN      A	    192.168.18.184
                ol9n-scan       IN      A       192.168.18.185
                ol9n-scan       IN      A       192.168.18.186
                ol9n-scan       IN      A       192.168.18.187 

###### CREATE 192.168.18.ZONE FOR REVERSE RESOLUTION UNDER /VAR/NAMED/DATA/

    [root@ol9dns ~]# vi /var/named/data/192.168.18.zone
                $ttl 38400
                @       IN      SOA     ol9dns.appsdba.info.     root.appsdba.info. (
                        2020032701      ;
                        3600    ;
                        3600    ;
                        604800  ;
                        86400 ) ;

                @       IN      NS      ol9dns.appsdba.info.
                201     IN      PTR     ol9dns.appsdba.info.
                121     IN      PTR     ol9n1.appsdba.info.
                122     IN      PTR     ol9n2.appsdba.info.
                151	    IN	    PTR	    ol9n1-vip.appsdba.info.
                152	    IN	    PTR	    ol9n2-vip.appsdba.info.
                184     IN      PTR     ol9n-scan.appsdba.info.
                185     IN      PTR     ol9n-scan.appsdba.info.
                186     IN      PTR     ol9n-scan.appsdba.info.
                187     IN      PTR     ol9n-scan.appsdba.info.


###### START AND ENABLE NAMED SERVICE 

    [root@ol9dns ~]# systemctl enable named
    [root@ol9dns ~]# systemctl start named

###### OPEN FIREWALL 

    [root@ol9dns ~]# firewall-cmd --zone=public --add-port=53/tcp --permanent
    [root@ol9dns ~]# firewall-cmd --zone=public --add-port=53/udp --permanent
    [root@ol9dns ~]# firewall-cmd --reload
    [root@ol9dns ~]# firewall-cmd --list-all

###### INSTALL NET TOOLS

    [root@ol9dns ~]# yum install -y netstat
    [root@ol9dns ~]# yum install -y net-tools

###### CHECK SERVICE

    [root@ol9dns ~]# netstat -tulpn | grep ":53"
                tcp        0      0 192.168.18.201:53       0.0.0.0:*               LISTEN      970/named
                tcp        0      0 127.0.0.1:53            0.0.0.0:*               LISTEN      970/named
                udp        0      0 192.168.18.201:53       0.0.0.0:*                           970/named
                udp        0      0 127.0.0.1:53            0.0.0.0:*                           970/named

###### writed by: Danilo Arruda
###### ter 19 fev 2025
