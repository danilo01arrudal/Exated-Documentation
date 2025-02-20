**INSTALL AND CONFIGURE DNS SERVER ON OL9.5**

> *The main purpose of installing an Oracle database is to provide a robust and scalable platform for data management. It allows companies to store, organize and access information efficiently, ensuring data integrity and security. In addition, Oracle offers advanced features for application development and data analysis, aiding in strategic decision-making.*

![oracle database 23ai logo.](https://github.com/danilo01arrudal/Exated/blob/main/Oracle_Database_23ai/images/1714697079871.png)

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
    [root@localhost ~]# hostnamectl set-hostname ol7dns
    [root@localhost ~]# hostnamectl --static 

###### CONFIGURE /ETC/HOSTS FILE

    [root@ol9dns ~]# vi /etc/hosts
                    127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
                    ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
                    192.168.18.201	ol9dns


