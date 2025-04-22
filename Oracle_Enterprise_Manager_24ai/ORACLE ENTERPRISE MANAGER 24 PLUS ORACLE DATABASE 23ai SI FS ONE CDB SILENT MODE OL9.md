**ORACLE ENTERPRISE MANAGER 24ai PLUS ORACLE DATABASE 19C SI FS ONE CDB SILENT MODE OL9.5**


> *Oracle Enterprise Manager 24ai is Oracle's modern management platform, enhanced with AI for managing Oracle Databases and Engineered Systems across on-premises and cloud. Key features include an AI-powered assistant, zero downtime monitoring and job system, highly available remote agents, container-based architecture, improved UI, and integration with OCI observability and AI services for enhanced insights, automation, and security.*

![oracle enterprise manager_24ai logo.](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24ai/images/images.png)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER
    
    [root@exated ~]# virt-install --virt-type kvm --name ol9d --memory 4096 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9d.qcow2,size=50

###### CONFIGURE HOSTNAME

    [root@ol9em24ai ~]# hostnamectl set-hostname ol9em24ai

###### INSTALL PRE-INSTALL PACKAGES

    [root@ol9em24ai ~]# yum install oracle-database-preinstall-19c

###### DISABLE SELINUX

    [root@ol9em24ai ~]# sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config && setenforce 0

###### CONFIGURE STATIC NETWORK

    [root@ol9em24ai ~]# nmcli device 
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    lo      loopback  connected (externally)  lo  

    [root@ol9em24ai ~]# nmcli connection show  
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  26097519-1cba-3447-8711-fb0800ba2366  ethernet  enp1s0 
    lo      7ac75b97-ee60-4288-90d8-a732972b360f  loopback  lo 

    [root@ol9em24ai ~]# nmcli con modify 'enp1s0' iframe enp1s0 ipv4.method manual ipv4.addresses 192.168.18.16/24 gw4 192.168.18.1
    [root@ol9em24ai ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.201
    [root@ol9em24ai ~]# nmcli con down 'enp1s0'
    [root@ol9em24ai ~]# nmcli con up 'enp1s0'

    [root@ol9em24ai ~]# ip addr show enp1s0
    2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:84:74:c7 brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.16/24 brd 192.168.18.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever

    [root@ol9em24ai ~]# ip route show
    default via 192.168.18.1 dev enp1s0 proto static metric 100 
    192.168.18.0/24 dev enp1s0 proto kernel scope link src 192.168.18.16 metric 100 

###### DISABLE AVAHI DAEMON

    [root@ol9em24ai ~]# systemctl disable avahi-daemon  

###### INSTALL PACKAGES

    [root@ol9em24ai ~]# yum install -y oracle-database-preinstall-19c.x86_64
    [root@ol9em24ai ~]# yum install make -y
    [root@ol9em24ai ~]# yum install binutils -y
    [root@ol9em24ai ~]# yum install gcc -y
    [root@ol9em24ai ~]# yum install libaio -y
    [root@ol9em24ai ~]# yum install glibc-common -y
    [root@ol9em24ai ~]# yum install libstdc++ -y
    [root@ol9em24ai ~]# yum install sysstat -y
    [root@ol9em24ai ~]# yum install glibc -y
    [root@ol9em24ai ~]# yum install glibc-devel.i686 -y
    [root@ol9em24ai ~]# yum install glibc-devel -y
    [root@ol9em24ai ~]# yum install libXtst -y
    [root@ol9em24ai ~]# yum install ntpd -y

###### DISABLE AVAHI DAEMON

    [root@ol9em24ai ~]# systemctl stop avahi-service
    [root@ol9em24ai ~]# systemctl stop avahi-daemon
    [root@ol9em24ai ~]# systemctl disable avahi-daemon

###### CONFIGURE CHRONY SERVICE

    [root@ol9em24ai ~]# yum install -y install chrony
    [root@ol9em24ai ~]# systemctl start chronyd
    [root@ol9em24ai ~]# systemctl enable chronyd

###### CREATE ORACLE_BASE AND ORACLE_HOME DIRECTORIES

    [root@ol9em24ai ~]# mkdir -p /u01/app/oracle/product/19.3.0/dbhome_1
    [root@ol9em24ai ~]# chown -R oracle:oinstall /u01
    [root@ol9em24ai ~]# chmod -R 775 /u01

###### CONFIGURE VARIABLES

    [root@ol9em24ai ~]# su - oracle
    [oracle@ol9em24ai ~]$ mkdir /home/oracle/scripts

    [oracle@ol9em24ai ~]$ cat > /home/oracle/scripts/setEnv.sh <<EOF
    # Oracle Settings
    export TMP=/tmp
    export TMPDIR=\$TMP

    export ORACLE_HOSTNAME=ol9em24ai.appsdba.info
    export ORACLE_UNQNAME=appscdb
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=\$ORACLE_BASE/product/19.3.0/dbhome_1
    export ORA_INVENTORY=/u01/app/oraInventory
    export ORACLE_SID=appscdb1
    export CV_ASSUME_DISTID='OL7'

    export PATH=/usr/sbin:/usr/local/bin:\$PATH
    export PATH=\$ORACLE_HOME/bin:\$PATH

    export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
    export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
    EOF

    [oracle@ol9em24ai ~]$ echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile 
    [oracle@ol9em24ai ~]$ cat > /home/oracle/scripts/start_all.sh <<EOF
    #!/bin/bash
    . /home/oracle/scripts/setEnv.sh

    export ORAENV_ASK=NO
    . oraenv
    export ORAENV_ASK=YES

    dbstart \$ORACLE_HOME
    EOF

    [oracle@ol9em24ai ~]$ cat > /home/oracle/scripts/stop_all.sh <<EOF
    #!/bin/bash
    . /home/oracle/scripts/setEnv.sh

    export ORAENV_ASK=NO
    . oraenv
    export ORAENV_ASK=YES

    dbshut \$ORACLE_HOME
    EOF

    [oracle@ol9em24ai ~]$ chown -R oracle:oinstall /home/oracle/scripts
    [oracle@ol9em24ai ~]$ chmod u+x /home/oracle/scripts/*.sh




