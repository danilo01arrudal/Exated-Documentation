**ORACLE DATABASE 23ai 2 NODE RAC MODE PLUS STORAGE ON OL9.5**

> *The main purpose of installing Oracle RAC is to provide high availability and horizontal scalability for Oracle databases. It allows multiple database instances to operate simultaneously on different servers, sharing the same data store. This ensures that, in the event of a server failure, the database remains accessible without interruption, and also allows processing capacity to be increased by adding new servers. Oracle RAC is ideal for mission-critical applications that require continuous performance and fault tolerance, optimizing resource utilization and improving response to increasing transaction demands.*

![oracle database 23ai logo.](https://github.com/danilo01arrudal/Exated/blob/main/Oracle_Database_23ai/images/1714697079871.png)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER OL9N1 

    virt-install --virt-type kvm --name ol9n1 --memory 8192 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --network bridge=br0,model=virtio --network network=priv0,model=virtio --disk path=/var/lib/libvirt/images/ol9n1.qcow2,size=59

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER OL9N2 

    virt-install --virt-type kvm --name ol9n2 --memory 8192 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --network bridge=br0,model=virtio --network network=priv0,model=virtio --disk path=/var/lib/libvirt/images/ol9n2.qcow2,size=59

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE STATIC NETWORK NODE 1)

    [root@ol9n1 ~]# hostnamectl set-hostname ol9n1

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE STATIC NETWORK NODE 2)

    [root@ol9n2 ~]# hostnamectl set-hostname ol9n2

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE STATIC NETWORK NODE 1)

    [root@ol9n1 ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    enp2s0  ethernet  conectado               enp2s0     
    enp3s0  ethernet  conectado               enp3s0     
    lo      loopback  connected (externally)  lo   
    [root@ol9n1 ~]# nmcli connection show  
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  266c6c59-2242-376f-932a-2fada4e31d3a  ethernet  enp1s0 
    enp2s0  3a982c55-28e5-3dd6-a476-a8d37a2eb1de  ethernet  enp2s0 
    enp3s0  5e71fb5c-912d-3e64-9093-67f57b60bf34  ethernet  enp3s0 
    lo      a5fbe03a-188f-4b0d-948c-93045f58939b  loopback  lo
    [root@ol9n1 ~]# nmcli con modify 'enp1s0' ifname enp1s0 ipv4.method manual ipv4.addresses 192.168.18.121/24 ipv4.gateway 192.168.18.1 autoconnect yes ipv6.method disabled
    [root@ol9n1 ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.201 
    [root@ol9n1 ~]# nmcli con down 'enp1s0'; nmcli con up 'enp1s0'  
    [root@ol9n1 ~]# ip addr show enp1s0
    2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:28:86:aa brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.121/24 brd 192.168.18.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever
    [root@ol9n1 ~]# nmcli con modify 'enp2s0' ifname enp2s0 ipv4.method manual ipv4.addresses 192.168.18.151/24 ipv4.gateway 192.168.18.1 autoconnect yes ipv6.method disabled 
    [root@ol9n1 ~]# nmcli con modify 'enp2s0' ipv4.dns 192.168.18.201 
    [root@ol9n1 ~]# nmcli con down 'enp2s0'
    [root@ol9n1 ~]# ip addr show enp2s0
    3: enp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:40:74:a1 brd ff:ff:ff:ff:ff:ff
    [root@ol9n1 ~]# nmcli con modify 'enp3s0' ifname enp3s0 ipv4.method manual ipv4.addresses 192.168.100.101/24 ipv4.gateway 192.168.100.1 autoconnect yes ipv6.method disabled
    [root@ol9n1 ~]# nmcli con down 'enp3s0'; nmcli con up 'enp3s0'
    [root@ol9n1 ~]# ip addr show enp3s0 
    4: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:7f:44:40 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.101/24 brd 192.168.100.255 scope global noprefixroute enp3s0
       valid_lft forever preferred_lft forever
    [root@ol9n1 ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    enp3s0  ethernet  conectado               enp3s0     
    lo      loopback  connected (externally)  lo         
    enp2s0  ethernet  desconectado            --         
    [root@ol9n1 ~]# nmcli connection show  
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  266c6c59-2242-376f-932a-2fada4e31d3a  ethernet  enp1s0 
    enp3s0  5e71fb5c-912d-3e64-9093-67f57b60bf34  ethernet  enp3s0 
    lo      a5fbe03a-188f-4b0d-948c-93045f58939b  loopback  lo     
    enp2s0  3a982c55-28e5-3dd6-a476-a8d37a2eb1de  ethernet  --       

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE STATIC NETWORK NODE 2)

    [root@ol9n2 ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    enp2s0  ethernet  conectado               enp2s0     
    enp3s0  ethernet  conectado               enp3s0     
    lo      loopback  connected (externally)  lo   
    [root@ol9n2 ~]# nmcli connection show  
    NAME    UUID                                  TYPE      DEVICE 
    enp3s0  c722a703-83de-36a0-ba0b-129c115b155b  ethernet  enp3s0 
    enp1s0  6970aff6-c896-396b-ada4-645795be91bb  ethernet  enp1s0 
    enp2s0  189431ad-d482-3853-86da-40818b54653f  ethernet  enp2s0 
    lo      c88169e7-1918-478d-8015-77da6638ee58  loopback  lo 
    [root@ol9n2 ~]# nmcli con modify 'enp1s0' ifname enp1s0 ipv4.method manual ipv4.addresses 192.168.18.122/24 ipv4.gateway 192.168.18.1 autoconnect yes ipv6.method disabled 
    [root@ol9n2 ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.201 
    [root@ol9n2 ~]# nmcli con down 'enp1s0'; nmcli con up 'enp1s0'
    [root@ol9n2 ~]# ip addr show enp1s0
    2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:6b:00:2d brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.122/24 brd 192.168.18.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever
    [root@ol9n2 ~]# nmcli con modify 'enp2s0' ifname enp2s0 ipv4.method manual ipv4.addresses 192.168.18.152/24 ipv4.gateway 192.168.18.1 autoconnect yes ipv6.method disabled 
    [root@ol9n2 ~]# nmcli con modify 'enp2s0' ipv4.dns 192.168.18.201 
    [root@ol9n2 ~]# nmcli con down 'enp2s0'
    Conexão “enp2s0” desativada com sucesso (caminho D-Bus ativo: /org/freedesktop/NetworkManager/ActiveConnection/5)
    [root@ol9n2 ~]# ip addr show enp2s0
    3: enp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:82:3a:0e brd ff:ff:ff:ff:ff:ff
    [root@ol9n2 ~]# nmcli con modify 'enp3s0' ifname enp3s0 ipv4.method manual ipv4.addresses 192.168.100.102/24 ipv4.gateway 192.168.100.1 autoconnect yes ipv6.method disabled 
    [root@ol9n2 ~]# nmcli con down 'enp3s0'; nmcli con up 'enp3s0' 
    Conexão “enp3s0” desativada com sucesso (caminho D-Bus ativo: /org/freedesktop/NetworkManager/ActiveConnection/4)
    Conexão ativada com sucesso (caminho D-Bus ativo: /org/freedesktop/NetworkManager/ActiveConnection/7)
    [root@ol9n2 ~]# ip addr show enp3s0  
    4: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:5d:35:1f brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.102/24 brd 192.168.100.255 scope global noprefixroute enp3s0
       valid_lft forever preferred_lft forever
    [root@ol9n2 ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    enp3s0  ethernet  conectado               enp3s0     
    lo      loopback  connected (externally)  lo         
    enp2s0  ethernet  desconectado            --         
    [root@ol9n2 ~]# nmcli connection show
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  6970aff6-c896-396b-ada4-645795be91bb  ethernet  enp1s0 
    enp3s0  c722a703-83de-36a0-ba0b-129c115b155b  ethernet  enp3s0 
    lo      c88169e7-1918-478d-8015-77da6638ee58  loopback  lo     
    enp2s0  189431ad-d482-3853-86da-40818b54653f  ethernet  --  

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( DISABLE FIREWALL AND SELINUX )

    [root@ol9n1 ~]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    [root@ol9n2 ~]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

    [root@ol9n1 ~]# systemctl stop firewalld; systemctl disable firewalld 
    [root@ol9n2 ~]# systemctl stop firewalld; systemctl disable firewalld

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( PACKAGES )

    [root@ol9n1 ~]# yum install -y oracle-database-preinstall-23ai.x86_64
    [root@ol9n2 ~]# yum install -y oracle-database-preinstall-23ai.x86_64
    [root@ol9n1 ~]# yum install -y https://yum.oracle.com/repo/OracleLinux/OL9/addons/x86_64/getPackage/oracleasm-support-3.0.0-7.el9.x86_64.rpm
    [root@ol9n2 ~]# yum install -y https://yum.oracle.com/repo/OracleLinux/OL9/addons/x86_64/getPackage/oracleasm-support-3.0.0-7.el9.x86_64.rpm
    [root@ol9n1 ~]# rpm -ivh oracleasmlib-3.0.0-13.el9.x86_64.rpm
    [root@ol9n2 ~]# rpm -ivh oracleasmlib-3.0.0-13.el9.x86_64.rpm
    [root@ol9n1 ~]# yum install -y chkconfig
    [root@ol9n2 ~]# yum install -y chkconfig
    [root@ol9n1 ~]# yum install -y iscsi-initiator-utils udisks2-iscsi 
    [root@ol9n2 ~]# yum install -y iscsi-initiator-utils udisks2-iscsi 

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( PLUGGABLE AUTHENTICATION MODULES )

    [root@ol9n1 ~]# echo "session         required        pam_limits.so" >> /etc/pam.d/su 
    [root@ol9n1 ~]# echo "session         required        pam_unix.so" >> /etc/pam.d/su
    [root@ol9n2 ~]# echo "session         required        pam_limits.so" >> /etc/pam.d/su 
    [root@ol9n2 ~]# echo "session         required        pam_unix.so" >> /etc/pam.d/su 
    [root@ol9n1 ~]# echo "session    required     pam_limits.so" >> /etc/pam.d/sshd
    [root@ol9n1 ~]# echo "session    required     pam_unix.so" >> /etc/pam.d/sshd
    [root@ol9n2 ~]# echo "session    required     pam_limits.so" >> /etc/pam.d/sshd
    [root@ol9n2 ~]# echo "session    required     pam_unix.so" >> /etc/pam.d/sshd
    [root@ol9n1 ~]# echo "session    required     pam_limits.so" >> /etc/pam.d/login
    [root@ol9n1 ~]# echo "session    required     pam_unix.so" >> /etc/pam.d/login
    [root@ol9n2 ~]# echo "session    required     pam_limits.so" >> /etc/pam.d/login
    [root@ol9n2 ~]# echo "session    required     pam_unix.so" >> /etc/pam.d/login

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( SECURITY LIMITS )

    [root@ol9n1 ~]# cat <<EOF >> /etc/security/limits.conf
    *    hard    nofile     327680
    *    soft    nofile     262144
    *    hard    nproc      327680
    *    soft    nproc      262144
    *    hard    memlock    3145728
    *    soft    memlock    3145728
    *    hard    stack      16384
    *    soft    stack      10240
    EOF
    [root@ol9n2 ~]# cat <<EOF >> /etc/security/limits.conf
    *    hard    nofile     327680
    *    soft    nofile     262144
    *    hard    nproc      327680
    *    soft    nproc      262144
    *    hard    memlock    3145728
    *    soft    memlock    3145728
    *    hard    stack      16384
    *    soft    stack      10240
    EOF

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CREATE USERS )

    [root@ol9n1 ~]# userdel oracle; rm -Rvf /home/oracle; rm -Rvf /var/mail/oracle 
    [root@ol9n2 ~]# userdel oracle; rm -Rvf /home/oracle; rm -Rvf /var/mail/oracle 
    [root@ol9n1 ~]# groupadd -g 54321 oinstall; groupadd -g 54322 dba; groupadd -g 54323 oper; groupadd -g 54324 backupdba; groupadd -g 54325 dgdba; groupadd -g 54326 kmdba; groupadd -g 54327 asmdba; groupadd -g 54328 asmoper; groupadd -g 54329 asmadmin; groupadd -g 54330 racdba; useradd -m -u 54331 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,asmdba,asmadmin,racdba -d /home/oracle -s /bin/bash  oracle; useradd -m -u 54332 -g oinstall -G dba,asmadmin,asmdba,asmoper -d /home/grid -s /bin/bash  grid; id oracle; id grid
    [root@ol9n2 ~]# groupadd -g 54321 oinstall; groupadd -g 54322 dba; groupadd -g 54323 oper; groupadd -g 54324 backupdba; groupadd -g 54325 dgdba; groupadd -g 54326 kmdba; groupadd -g 54327 asmdba; groupadd -g 54328 asmoper; groupadd -g 54329 asmadmin; groupadd -g 54330 racdba; useradd -m -u 54331 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,asmdba,asmadmin,racdba -d /home/oracle -s /bin/bash  oracle; useradd -m -u 54332 -g oinstall -G dba,asmadmin,asmdba,asmoper -d /home/grid -s /bin/bash  grid; id oracle; id grid
    [root@ol9n1 ~]# passwd oracle
    [root@ol9n2 ~]# passwd oracle
    [root@ol9n1 ~]# passwd grid
    [root@ol9n2 ~]# passwd grid

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CREATE DIRECTORIES )

    [root@ol9n1 ~]# mkdir -p /u01/app/grid; mkdir -p /u01/app/23.7.0/grid; mkdir -p /u01/app/oracle; mkdir -p /u01/app/oracle/product/23.7.0/dbhome_1; chmod -R 775 /u01; chown -R grid:oinstall /u01; chown -R oracle:oinstall /u01/app/oracle; chown oracle:oinstall -R /home/oracle
    [root@ol9n2 ~]# mkdir -p /u01/app/grid; mkdir -p /u01/app/23.7.0/grid; mkdir -p /u01/app/oracle; mkdir -p /u01/app/oracle/product/23.7.0/dbhome_1; chmod -R 775 /u01; chown -R grid:oinstall /u01; chown -R oracle:oinstall /u01/app/oracle; chown oracle:oinstall -R /home/oracle

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE /ETC/HOSTS )

    [root@ol9n1 ~]# cat <<EOF >> /etc/hosts 
    # bridge
    # Public Network - (enp1s0)
    192.168.1.121 ol9n1.appsdba.info ol9n1
    192.168.1.122 ol9n2.appsdba.info ol9n2
 
    # Internal Network
    # Private Interconnect - (enp3s0)
    192.168.100.101 ol9n1-priv.appsdba.info ol9n1-priv
    192.168.100.102 ol9n2-priv.appsdba.info ol9n2-priv
 
    # Public Virtual IP (VIP) addresses for - (enp2s0)
    192.168.18.151 ol9n1-vip.appsdba.info ol9n1-vip
    192.168.18.152 ol9n2-vip.appsdba.info ol9n2-vip
    EOF
    [root@ol9n2 ~]# cat <<EOF >> /etc/hosts 
    # bridge
    # Public Network - (enp1s0)
    192.168.1.121 ol9n1.appsdba.info ol9n1
    192.168.1.122 ol9n2.appsdba.info ol9n2
 
    # Internal Network
    # Private Interconnect - (enp3s0)
    192.168.100.101 ol9n1-priv.appsdba.info ol9n1-priv
    192.168.100.102 ol9n2-priv.appsdba.info ol9n2-priv
 
    # Public Virtual IP (VIP) addresses for - (enp2s0)
    192.168.18.151 ol9n1-vip.appsdba.info ol9n1-vip
    192.168.18.152 ol9n2-vip.appsdba.info ol9n2-vip
    EOF

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE /ETC/RESOLV.CONF )

    [root@ol9n1 ~]# cat <<EOF > /etc/resolv.conf
    # Generated by NetworkManager
    search appsdba.info
    nameserver 192.168.18.201
    EOF
    [root@ol9n1 ~]# chattr +i /etc/resolv.conf
    [root@ol9n2 ~]# cat <<EOF > /etc/resolv.conf
    # Generated by NetworkManager
    search appsdba.info
    nameserver 192.168.18.201
    EOF
    [root@ol9n2 ~]# chattr +i /etc/resolv.conf

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( ENVIRONMENT VARIABLES NODE 1 )

    [root@ol9n1 ~]# cat <<EOF > /home/grid/.bash_profile 
    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
            . ~/.bashrc
    fi

    # User specific environment and startup program

    PATH=$PATH:$HOME/.local/bin:$HOME/bin
    export ORACLE_SID=+ASM1
    export ORACLE_BASE=/u01/app/grid
    export ORACLE_HOME=/u01/app/23.7.0/grid
    export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
    umask 22
    export PATH
    EOF
    [root@ol9n1 ~]# chown grid:oinstall /home/grid/.bash_profile
    [root@ol9n1 ~]# cat <<EOF > /home/oracle/.bash_profile
    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi

    # User specific environment and startup programs

    PATH=$PATH:$HOME/.local/bin:$HOME/bin
    export ORACLE_SID=oradbc1
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=$ORACLE_BASE/product/23.7.0/dbhome_1
    export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
    umask 22
    export PATH
    EOF
    [root@ol9n1 ~]# chown oracle:oinstall /home/oracle/.bash_profile
    [root@ol9n1 ~]# cat <<EOF > /root/.bash_profile 
    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi

    # User specific environment and startup programs

    PATH=$PATH:$HOME/bin
    export ORACLE_HOME=/u01/app/23.7.0/grid
    export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
    export PATH
    EOF
    
###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( ENVIRONMENT VARIABLES NODE 2 )

    [root@ol9n2 ~]# cat <<EOF > /home/grid/.bash_profile 
    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
            . ~/.bashrc
    fi

    # User specific environment and startup program

    PATH=$PATH:$HOME/.local/bin:$HOME/bin
    export ORACLE_SID=+ASM2
    export ORACLE_BASE=/u01/app/grid
    export ORACLE_HOME=/u01/app/23.7.0/grid
    export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
    umask 22
    export PATH
    EOF
    [root@ol9n2 ~]# chown grid:oinstall /home/grid/.bash_profile
    [root@ol9n2 ~]# cat <<EOF > /home/oracle/.bash_profile
    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi

    # User specific environment and startup programs

    PATH=$PATH:$HOME/.local/bin:$HOME/bin
    export ORACLE_SID=oradbc2
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=$ORACLE_BASE/product/23.7.0/dbhome_1
    export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
    umask 22
    export PATH
    EOF
    [root@ol9n2 ~]# chown oracle:oinstall /home/oracle/.bash_profile
    [root@ol9n2 ~]# cat <<EOF > /root/.bash_profile 
    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi

    # User specific environment and startup programs

    PATH=$PATH:$HOME/bin
    export ORACLE_HOME=/u01/app/23.7.0/grid
    export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
    export PATH
    EOF

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE ORACLE ASM LIBRARY NODE 1 )
    
    [root@ol9n1 ~]# source /root/.bash_profile
    [root@ol9n1 ~]# oracleasm configure -i
    Configuring the Oracle ASM library driver.

    This will configure the on-boot properties of the Oracle ASM library
    driver.  The following questions will determine whether the driver is
    loaded on boot and what permissions it will have.  The current values
    will be shown in brackets ('[]').  Hitting <ENTER> without typing an
    answer will keep that current value.  Ctrl-C will abort.

    Default user to own the driver interface []: oracle
    Default group to own the driver interface []: oinstall
    Start Oracle ASM library driver on boot (y/n) [n]: y
    Scan for Oracle ASM disks on boot (y/n) [y]: y
    Maximum number of disks that may be used in ASM system [2048]: 
    Enable iofilter if kernel supports it (y/n) [y]: y
    Writing Oracle ASM library driver configuration: done

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE ORACLE ASM LIBRARY NODE 2 )

    [root@ol9n2 ~]# source /root/.bash_profile
    [root@ol9n2 ~]# oracleasm configure -i
    Configuring the Oracle ASM library driver.

    This will configure the on-boot properties of the Oracle ASM library
    driver.  The following questions will determine whether the driver is
    loaded on boot and what permissions it will have.  The current values
    will be shown in brackets ('[]').  Hitting <ENTER> without typing an
    answer will keep that current value.  Ctrl-C will abort.

    Default user to own the driver interface []: oracle
    Default group to own the driver interface []: oinstall
    Start Oracle ASM library driver on boot (y/n) [n]: y
    Scan for Oracle ASM disks on boot (y/n) [y]: y
    Maximum number of disks that may be used in ASM system [2048]: 
    Enable iofilter if kernel supports it (y/n) [y]: y
    Writing Oracle ASM library driver configuration: done

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( GET ISCSI ID )

    [root@ol9n1 ~]# iscsiadm -m discovery -t sendtargets -p 192.168.18.200 
    192.168.18.200:3260,1 iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0
    [root@ol9n2 ~]# iscsiadm -m discovery -t sendtargets -p 192.168.18.200
    192.168.18.200:3260,1 iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0
    [root@ol9n1 ~]# cat /etc/iscsi/initiatorname.iscsi
    InitiatorName=iqn.1988-12.com.oracle:58e84cb3eaf6
    [root@ol9n2 ~]# cat /etc/iscsi/initiatorname.iscsi
    InitiatorName=iqn.1988-12.com.oracle:e647892de987
    
###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( LOGIN ISCSI )
    
    [root@ol9n1 ~]# iscsiadm -m node -T  iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0 -p 192.168.18.200 -l
    Logging in to [iface: default, target: iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0, portal: 192.168.18.200,3260]
    Login to [iface: default, target: iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0, portal: 192.168.18.200,3260] successful.
    [root@ol9n2 ~]# iscsiadm -m node -T  iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0 -p 192.168.18.200 -l 
    Logging in to [iface: default, target: iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0, portal: 192.168.18.200,3260]
    Login to [iface: default, target: iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0, portal: 192.168.18.200,3260] successful.
    
###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( AUTOMATIC LOGIN ISCSI )

    [root@ol9n1 ~]# iscsiadm -m node -T iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0 -p 192.168.18.200 -o update -n node.startup -v automatic
    [root@ol9n2 ~]# iscsiadm -m node -T iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0 -p 192.168.18.200 -o update -n node.startup -v automatic

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CHECK ISCSI DISKS )

    [root@ol9n1 ~]# fdisk -l | grep "Disco /dev/sd"
    Disco /dev/sda: 20 GiB, 21474836480 bytes, 41943040 setores
    Disco /dev/sde: 20 GiB, 21474836480 bytes, 41943040 setores
    Disco /dev/sdb: 20 GiB, 21474836480 bytes, 41943040 setores
    Disco /dev/sdd: 20 GiB, 21474836480 bytes, 41943040 setores
    Disco /dev/sdc: 20 GiB, 21474836480 bytes, 41943040 setores
    [root@ol9n2 ~]# fdisk -l | grep "Disco /dev/sd" 
    Disco /dev/sda: 20 GiB, 21474836480 bytes, 41943040 setores
    Disco /dev/sdb: 20 GiB, 21474836480 bytes, 41943040 setores
    Disco /dev/sdd: 20 GiB, 21474836480 bytes, 41943040 setores
    Disco /dev/sde: 20 GiB, 21474836480 bytes, 41943040 setores
    Disco /dev/sdc: 20 GiB, 21474836480 bytes, 41943040 setores

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CREATE PARTITION ISCSI DISKS )

    [root@ol9n1 ~]# fdisk /dev/sda
    n > p > 1 > w
    [root@ol9n1 ~]# fdisk /dev/sdb
    n > p > 1 > w
    [root@ol9n1 ~]# fdisk /dev/sdc
    n > p > 1 > w
    [root@ol9n1 ~]# fdisk /dev/sdd
    n > p > 1 > w
    [root@ol9n1 ~]# fdisk /dev/sde
    n > p > 1 > w

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( GET ISCSI DISKS UUID )

    [root@ol9n1 ~]# /usr/lib/udev/scsi_id -g -u -d /dev/sda1 
    36001405c2b1cd5d2f25490fa18a78e36
    [root@ol9n1 ~]# /usr/lib/udev/scsi_id -g -u -d /dev/sdb1 
    360014058c1b0ce71fe24475aa4139ecc
    [root@ol9n1 ~]# /usr/lib/udev/scsi_id -g -u -d /dev/sdc1 
    360014051c3e44ceaf57418fa35d05cb5
    [root@ol9n1 ~]# /usr/lib/udev/scsi_id -g -u -d /dev/sdd1 
    36001405e87d20fdda164e60bd17dac7d
    [root@ol9n1 ~]# /usr/lib/udev/scsi_id -g -u -d /dev/sde1 
    3600140590bc1307e3a44a679c89c7014

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CREATE ASM DEVICES RULES )

    [root@ol9n1 ~]# cat <<EOF > /etc/udev/rules.d/99-oracle-asmdevices.rules
    KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="36001405c2b1cd5d2f25490fa18a78e36", SYMLINK+="asm-disk1", OWNER="grid", GROUP="asmadmin", MODE="0660"
    KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="360014058c1b0ce71fe24475aa4139ecc", SYMLINK+="asm-disk2", OWNER="grid", GROUP="asmadmin", MODE="0660"
    KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="360014051c3e44ceaf57418fa35d05cb5", SYMLINK+="asm-disk3", OWNER="grid", GROUP="asmadmin", MODE="0660"
    KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="36001405e87d20fdda164e60bd17dac7d", SYMLINK+="asm-disk4", OWNER="grid", GROUP="asmadmin", MODE="0660"
    KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="3600140590bc1307e3a44a679c89c7014", SYMLINK+="asm-disk5", OWNER="grid", GROUP="asmadmin", MODE="0660"
    EOF
    [root@ol9n2 ~]# cat <<EOF > /etc/udev/rules.d/99-oracle-asmdevices.rules
    KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="36001405c2b1cd5d2f25490fa18a78e36", SYMLINK+="asm-disk1", OWNER="grid", GROUP="asmadmin", MODE="0660"
    KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="360014058c1b0ce71fe24475aa4139ecc", SYMLINK+="asm-disk2", OWNER="grid", GROUP="asmadmin", MODE="0660"
    KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="360014051c3e44ceaf57418fa35d05cb5", SYMLINK+="asm-disk3", OWNER="grid", GROUP="asmadmin", MODE="0660"
    KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="36001405e87d20fdda164e60bd17dac7d", SYMLINK+="asm-disk4", OWNER="grid", GROUP="asmadmin", MODE="0660"
    KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="3600140590bc1307e3a44a679c89c7014", SYMLINK+="asm-disk5", OWNER="grid", GROUP="asmadmin", MODE="0660"
    EOF

    [root@ol9n1 ~]# udevadm test /block/sda/sda1
    [root@ol9n1 ~]# udevadm test /block/sdb/sdb1
    [root@ol9n1 ~]# udevadm test /block/sdc/sdc1
    [root@ol9n1 ~]# udevadm test /block/sdd/sdd1
    [root@ol9n1 ~]# udevadm test /block/sde/sde1
    [root@ol9n1 ~]# udevadm control --reload-rules
    [root@ol9n1 ~]# /sbin/udevadm trigger
    [root@ol9n2 ~]# udevadm test /block/sda/sda1
    [root@ol9n2 ~]# udevadm test /block/sdb/sdb1
    [root@ol9n2 ~]# udevadm test /block/sdc/sdc1
    [root@ol9n2 ~]# udevadm test /block/sdd/sdd1
    [root@ol9n2 ~]# udevadm test /block/sde/sde1
    [root@ol9n2 ~]# udevadm control --reload-rules
    [root@ol9n2 ~]# /sbin/udevadm trigger

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CHECK ASM DEVICES RULES )

    [root@ol9n1 ~]# ls -ltr /dev/asm-disk*
    lrwxrwxrwx 1 root root 4 fev 28 14:34 /dev/asm-disk1 -> sda1
    [root@ol9n1 ~]# ls -ltr /dev/sda1
    brw-rw---- 1 grid asmadmin 8, 1 fev 28 14:34 /dev/sda1

###### SSH KEY EXCHANGE ( NODE 1 )

    [root@ol9n1 ~]# su - root -c "ssh-keygen -t rsa"
    [root@ol9n1 ~]# su - oracle -c "ssh-keygen -t rsa"
    [root@ol9n1 ~]# su - grid -c "ssh-keygen -t rsa"
    [root@ol9n1 ~]# su - root -c "cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys"
    [root@ol9n1 ~]# su - oracle -c "cat /home/oracle/.ssh/id_rsa.pub > /home/oracle/.ssh/authorized_keys"
    [root@ol9n1 ~]# su - grid -c "cat /home/grid/.ssh/id_rsa.pub > /home/grid/.ssh/authorized_keys"
    
###### SSH KEY EXCHANGE ( NODE 2 )

    [root@ol9n2 ~]# su - root -c "ssh-keygen -t rsa"
    [root@ol9n2 ~]# su - oracle -c "ssh-keygen -t rsa"
    [root@ol9n2 ~]# su - grid -c "ssh-keygen -t rsa"
    [root@ol9n2 ~]# su - root -c "cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys"
    [root@ol9n2 ~]# su - oracle -c "cat /home/oracle/.ssh/id_rsa.pub > /home/oracle/.ssh/authorized_keys"
    [root@ol9n2 ~]# su - grid -c "cat /home/grid/.ssh/id_rsa.pub > /home/grid/.ssh/authorized_keys"

###### COPY GRID INFRASTRUCTURE SOFTWARE

    [root@exated Downloads]# scp p37370503_230000_Linux-x86-64.zip grid@192.168.18.121:/u01/app/23.7.0/grid








