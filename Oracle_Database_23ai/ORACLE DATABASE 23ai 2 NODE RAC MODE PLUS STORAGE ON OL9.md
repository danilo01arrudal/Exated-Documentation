**ORACLE DATABASE 23ai 2 NODE RAC MODE PLUS STORAGE ON OL9.5**

> *The main purpose of installing Oracle RAC is to provide high availability and horizontal scalability for Oracle databases. It allows multiple database instances to operate simultaneously on different servers, sharing the same data store. This ensures that, in the event of a server failure, the database remains accessible without interruption, and also allows processing capacity to be increased by adding new servers. Oracle RAC is ideal for mission-critical applications that require continuous performance and fault tolerance, optimizing resource utilization and improving response to increasing transaction demands.*

![oracle database 23ai logo.](https://github.com/danilo01arrudal/Exated/blob/main/Oracle_Database_23ai/images/1714697079871.png)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER OL9N1 

    virt-install --virt-type kvm --name ol9n1 --memory 8192 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --network bridge=br0,model=virtio --network network=priv0,model=virtio --disk path=/var/lib/libvirt/images/ol9n1.qcow2,size=59

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER OL9N2 

    virt-install --virt-type kvm --name ol9n2 --memory 8192 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --network bridge=br0,model=virtio --network network=priv0,model=virtio --disk path=/var/lib/libvirt/images/ol9n2.qcow2,size=59

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CHANGE THE CLOCK SOURCE IN THE SYSTEM )

    [root@ol9n1 ~]# cat /sys/devices/system/clocksource/clocksource0/current_clocksource
    kvm-clock
    [root@ol9n1 ~]# cat /sys/devices/system/clocksource/clocksource0/available_clocksource
    kvm-clock tsc acpi_pm 
    [root@ol9n1 ~]# vi /sys/devices/system/clocksource/clocksource0/current_clocksource
    tsc
    [root@ol9n2 ~]# vi /sys/devices/system/clocksource/clocksource0/current_clocksource
    tsc

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE STATIC NETWORK NODE 1)

    [root@ol9n1 ~]# hostnamectl set-hostname ol9n1.appsdba.info

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE STATIC NETWORK NODE 2)

    [root@ol9n2 ~]# hostnamectl set-hostname ol9n2.appsdba.info

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

    [root@ol9n1 ~]# systemctl disable avahi-daemon.socket avahi-daemon.service 
    Removed "/etc/systemd/system/multi-user.target.wants/avahi-daemon.service".
    Removed "/etc/systemd/system/sockets.target.wants/avahi-daemon.socket".
    Removed "/etc/systemd/system/dbus-org.freedesktop.Avahi.service".
    [root@ol9n1 ~]# systemctl mask avahi-daemon.socket avahi-daemon.service 
    Created symlink /etc/systemd/system/avahi-daemon.socket → /dev/null.
    Created symlink /etc/systemd/system/avahi-daemon.service → /dev/null.
    [root@ol9n1 ~]# systemctl stop avahi-daemon.socket avahi-daemon.service

    [root@ol9n2 ~]# systemctl disable avahi-daemon.socket avahi-daemon.service
    Removed "/etc/systemd/system/multi-user.target.wants/avahi-daemon.service".
    Removed "/etc/systemd/system/dbus-org.freedesktop.Avahi.service".
    Removed "/etc/systemd/system/sockets.target.wants/avahi-daemon.socket".
    [root@ol9n2 ~]# systemctl mask avahi-daemon.socket avahi-daemon.service 
    Created symlink /etc/systemd/system/avahi-daemon.socket → /dev/null.
    Created symlink /etc/systemd/system/avahi-daemon.service → /dev/null.
    [root@ol9n2 ~]# systemctl stop avahi-daemon.socket avahi-daemon.service

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

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE /ETC/RESOLV.CONF )

    [root@ol9n1 ~]# cat <<EOF > /etc/resolv.conf
    nameserver 192.168.18.201
    search appsdba.info
    EOF
    [root@ol9n1 ~]# chattr +i /etc/resolv.conf
    [root@ol9n2 ~]# cat <<EOF > /etc/resolv.conf
    nameserver 192.168.18.201
    search appsdba.info
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
    export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH
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
    export ORACLE_HOME=\$ORACLE_BASE/product/23.7.0/dbhome_1
    export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH
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
    export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH
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
    export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH
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
    export ORACLE_HOME=\$ORACLE_BASE/product/23.7.0/dbhome_1
    export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH
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
    export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH
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
    [root@ol9n1 ~]# chmod 600 /root/.ssh/authorized_keys
    [root@ol9n1 ~]# chmod 600 /home/oracle/.ssh/authorized_keys
    [root@ol9n1 ~]# chmod 600 /home/grid/.ssh/authorized_keys
    [root@ol9n1 ~]# ssh-copy-id -i .ssh/id_rsa.pub root@192.168.18.122
    [root@ol9n1 ~]# su - oracle
    [oracle@ol9n1 ~]$ ssh-copy-id -i .ssh/id_rsa.pub oracle@192.168.18.122
    [oracle@ol9n1 ~]$ exit
    [root@ol9n1 ~]# su - grid
    [grid@ol9n1 ~]$ ssh-copy-id -i .ssh/id_rsa.pub grid@192.168.18.122
    [grid@ol9n1 ~]$ exit
    
###### SSH KEY EXCHANGE ( NODE 2 )

    [root@ol9n2 ~]# su - root -c "ssh-keygen -t rsa"
    [root@ol9n2 ~]# su - oracle -c "ssh-keygen -t rsa"
    [root@ol9n2 ~]# su - grid -c "ssh-keygen -t rsa"
    [root@ol9n2 ~]# su - root -c "cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys"
    [root@ol9n2 ~]# su - oracle -c "cat /home/oracle/.ssh/id_rsa.pub > /home/oracle/.ssh/authorized_keys"
    [root@ol9n2 ~]# su - grid -c "cat /home/grid/.ssh/id_rsa.pub > /home/grid/.ssh/authorized_keys"
    [root@ol9n2 ~]# chmod 600 /root/.ssh/authorized_keys
    [root@ol9n2 ~]# chmod 600 /home/oracle/.ssh/authorized_keys
    [root@ol9n2 ~]# chmod 600 /home/grid/.ssh/authorized_keys
    [root@ol9n2 ~]# ssh-copy-id -i .ssh/id_rsa.pub root@192.168.18.121
    [root@ol9n2 ~]# su - oracle
    [oracle@ol9n2 ~]$ ssh-copy-id -i .ssh/id_rsa.pub oracle@192.168.18.121
    [oracle@ol9n2 ~]$ exit
    [root@ol9n2 ~]# su - grid
    [grid@ol9n2 ~]$ ssh-copy-id -i .ssh/id_rsa.pub grid@192.168.18.121
    [grid@ol9n2 ~]$ exit
    
###### COPY GRID INFRASTRUCTURE SOFTWARE

    [root@exated Downloads]# scp p37370503_230000_Linux-x86-64.zip grid@192.168.18.121:/u01/app/23.7.0/grid

###### UNZIP GRID INFRASTRUCTURE SOFTWARE

    [root@ol9n1 ~]# su - grid
    [grid@ol9n1 grid]$ cd /u01/app/23.7.0/grid/
    [grid@ol9n1 grid]$ unzip p37370503_230000_Linux-x86-64.zip
    [grid@ol9n1 grid]$ rm -vf p37370503_230000_Linux-x86-64.zip

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( INSTALL CVU PACKAGE )

    [root@ol9n1 ~]# rpm -ivh /u01/app/23.7.0/grid/cv/rpm/cvuqdisk-1.0.10-1.rpm 
    aviso: /u01/app/23.7.0/grid/cv/rpm/cvuqdisk-1.0.10-1.rpm: Cabeçalho V3 RSA/SHA256 Signature, ID da chave ad986da3: NOKEY
    Verifying...                          ################################# [100%]
    Preparando...                         ################################# [100%]
    Using default group oinstall to install package
    Updating / installing...
        1:cvuqdisk-1.0.10-1                ################################# [100%]
    [root@ol9n1 ~]# scp /u01/app/23.7.0/grid/cv/rpm/cvuqdisk-1.0.10-1.rpm root@ol9n2:/root/
    [root@ol9n1 ~]# ssh root@ol9n2
    [root@ol9n2 ~]# rpm -ivh cvuqdisk-1.0.10-1.rpm 
    aviso: cvuqdisk-1.0.10-1.rpm: Cabeçalho V3 RSA/SHA256 Signature, ID da chave ad986da3: NOKEY
    Verifying...                          ################################# [100%]
    Preparando...                         ################################# [100%]
    Using default group oinstall to install package
    Updating / installing...
       1:cvuqdisk-1.0.10-1                ################################# [100%]
    [root@ol9n2 ~]# exit

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( RUNCLUVFY )

    [root@ol9n1 ~]# su - grid
    [grid@ol9n1 ~]$ /u01/app/23.7.0/grid/runcluvfy.sh stage -pre crsinst -n ol9n1,ol9n2 -verbose -method root
    Digite a senha de "ROOT":

    Performing following verification checks ...

    Memória Física ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         7,7478GB (8124168.0KB)    8GB (8388608.0KB)         aprovado  
    ol9n1         7,7478GB (8124160.0KB)    8GB (8388608.0KB)         aprovado  
    Memória Física ...APROVADO
    Memória Física Disponível ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         7,3125GB (7667700.0KB)    50MB (51200.0KB)          aprovado  
    ol9n1         7,0345GB (7376172.0KB)    50MB (51200.0KB)          aprovado  
    Memória Física Disponível ...APROVADO
    Tamanho de Swap ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         8GB (8388604.0KB)         7,7478GB (8124168.0KB)    aprovado  
    ol9n1         8GB (8388604.0KB)         7,7478GB (8124160.0KB)    aprovado  
    Tamanho de Swap ...APROVADO
    Espaço Livre: ol9n2:/usr,ol9n2:/var,ol9n2:/etc,ol9n2:/sbin,ol9n2:/tmp ...
    Caminho           Nome do Nó    Ponto de montagem  Disponível    Necessário    Status      
    ----------------  ------------  ------------  ------------  ------------  ------------
    /usr              ol9n2         /             42,4229GB     25MB          aprovado    
    /var              ol9n2         /             42,4229GB     5MB           aprovado    
    /etc              ol9n2         /             42,4229GB     25MB          aprovado    
    /sbin             ol9n2         /             42,4229GB     10MB          aprovado    
    /tmp              ol9n2         /             42,4229GB     1GB           aprovado    
    Espaço Livre: ol9n2:/usr,ol9n2:/var,ol9n2:/etc,ol9n2:/sbin,ol9n2:/tmp ...APROVADO
    Espaço Livre: ol9n1:/usr,ol9n1:/var,ol9n1:/etc,ol9n1:/sbin,ol9n1:/tmp ...
    Caminho           Nome do Nó    Ponto de montagem  Disponível    Necessário    Status      
    ----------------  ------------  ------------  ------------  ------------  ------------
    /usr              ol9n1         /             39,7291GB     25MB          aprovado    
    /var              ol9n1         /             39,7291GB     5MB           aprovado    
    /etc              ol9n1         /             39,7291GB     25MB          aprovado    
    /sbin             ol9n1         /             39,7291GB     10MB          aprovado    
    /tmp              ol9n1         /             39,7291GB     1GB           aprovado    
    Espaço Livre: ol9n1:/usr,ol9n1:/var,ol9n1:/etc,ol9n1:/sbin,ol9n1:/tmp ...APROVADO
    Existência de Usuário: grid ...
    Nome do Nó    Status                    Comentário              
    ------------  ------------------------  ------------------------
    ol9n2         aprovado                  existe(54332)           
    ol9n1         aprovado                  existe(54332)           

    Usuários com o Mesmo UID: 54332 ...APROVADO
    Existência de Usuário: grid ...APROVADO
    Existência de Grupo: asmadmin ...
    Nome do Nó    Status                    Comentário              
    ------------  ------------------------  ------------------------
    ol9n2         aprovado                  existe                  
    ol9n1         aprovado                  existe                  
    Existência de Grupo: asmadmin ...APROVADO
    Existência de Grupo: asmdba ...
    Nome do Nó    Status                    Comentário              
    ------------  ------------------------  ------------------------
    ol9n2         aprovado                  existe                  
    ol9n1         aprovado                  existe                  
    Existência de Grupo: asmdba ...APROVADO
    Existência de Grupo: oinstall ...
    Nome do Nó    Status                    Comentário              
    ------------  ------------------------  ------------------------
    ol9n2         aprovado                  existe                  
    ol9n1         aprovado                  existe                  
    Existência de Grupo: oinstall ...APROVADO
    Participação em Grupos: asmdba ...
    Nome do Nó        O Usuário Já Existe  O Grupo Já Existe  Usuário no Grupo  Status          
    ----------------  ------------  ------------  ------------  ----------------
    ol9n2             sim           sim           sim           aprovado        
    ol9n1             sim           sim           sim           aprovado        
    Participação em Grupos: asmdba ...APROVADO
    Participação em Grupos: asmadmin ...
    Nome do Nó        O Usuário Já Existe  O Grupo Já Existe  Usuário no Grupo  Status          
    ----------------  ------------  ------------  ------------  ----------------
    ol9n2             sim           sim           sim           aprovado        
    ol9n1             sim           sim           sim           aprovado        
    Participação em Grupos: asmadmin ...APROVADO
    Participação em Grupos: oinstall(Principal) ...
    Nome do Nó        O Usuário Já Existe  O Grupo Já Existe  Usuário no Grupo  Principal     Status      
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n2             sim           sim           sim           sim           aprovado    
    ol9n1             sim           sim           sim           sim           aprovado    
    Participação em Grupos: oinstall(Principal) ...APROVADO
    Nível da Execução ...
    Nome do Nó    nível de execução         Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         5                         3,5                       aprovado  
    ol9n1         5                         3,5                       aprovado  
    Nível da Execução ...APROVADO
    Arquitetura ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         x86_64                    x86_64                    aprovado  
    ol9n1         x86_64                    x86_64                    aprovado  
    Arquitetura ...APROVADO
    Versão do Kernel do SO ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         5.15.0-302.167.6.el9uek.x86_64  5.15.0              aprovado  
    ol9n1         5.15.0-302.167.6.el9uek.x86_64  5.15.0              aprovado  
    Versão do Kernel do SO ...APROVADO
    Parâmetro de Kernel do SO: semmsl ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             250           250           250           aprovado    
    ol9n2             250           250           250           aprovado    
    Parâmetro de Kernel do SO: semmsl ...APROVADO
    Parâmetro de Kernel do SO: semmns ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             32000         32000         32000         aprovado    
    ol9n2             32000         32000         32000         aprovado    
    Parâmetro de Kernel do SO: semmns ...APROVADO
    Parâmetro de Kernel do SO: semopm ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             100           100           100           aprovado    
    ol9n2             100           100           100           aprovado    
    Parâmetro de Kernel do SO: semopm ...APROVADO
    Parâmetro de Kernel do SO: semmni ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             128           128           128           aprovado    
    ol9n2             128           128           128           aprovado    
    Parâmetro de Kernel do SO: semmni ...APROVADO
    Parâmetro de Kernel do SO: shmmax ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             4398046511104  4398046511104  4159569920  aprovado    
    ol9n2             4398046511104  4398046511104  4159574016  aprovado    
    Parâmetro de Kernel do SO: shmmax ...APROVADO
    Parâmetro de Kernel do SO: shmmni ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             4096          4096          4096          aprovado    
    ol9n2             4096          4096          4096          aprovado    
    Parâmetro de Kernel do SO: shmmni ...APROVADO
    Parâmetro de Kernel do SO: shmall ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             1073741824    1073741824    1073741824    aprovado    
    ol9n2             1073741824    1073741824    1073741824    aprovado    
    Parâmetro de Kernel do SO: shmall ...APROVADO
    Parâmetro de Kernel do SO: file-max ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             6815744       6815744       6815744       aprovado    
    ol9n2             6815744       6815744       6815744       aprovado    
    Parâmetro de Kernel do SO: file-max ...APROVADO
    Parâmetro de Kernel do SO: ip_local_port_range ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             between 9000 & 65535  between 9000 & 65535  between 9000 & 65535  aprovado    
    ol9n2             between 9000 & 65535  between 9000 & 65535  between 9000 & 65535  aprovado    
    Parâmetro de Kernel do SO: ip_local_port_range ...APROVADO
    Parâmetro de Kernel do SO: rmem_default ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             262144        262144        262144        aprovado    
    ol9n2             262144        262144        262144        aprovado    
    Parâmetro de Kernel do SO: rmem_default ...APROVADO
    Parâmetro de Kernel do SO: rmem_max ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             4194304       4194304       4194304       aprovado    
    ol9n2             4194304       4194304       4194304       aprovado    
    Parâmetro de Kernel do SO: rmem_max ...APROVADO
    Parâmetro de Kernel do SO: wmem_default ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             262144        262144        262144        aprovado    
    ol9n2             262144        262144        262144        aprovado    
    Parâmetro de Kernel do SO: wmem_default ...APROVADO
    Parâmetro de Kernel do SO: wmem_max ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             1048576       1048576       1048576       aprovado    
    ol9n2             1048576       1048576       1048576       aprovado    
    Parâmetro de Kernel do SO: wmem_max ...APROVADO
    Parâmetro de Kernel do SO: aio-max-nr ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             1048576       1048576       1048576       aprovado    
    ol9n2             1048576       1048576       1048576       aprovado    
    Parâmetro de Kernel do SO: aio-max-nr ...APROVADO
    Parâmetro de Kernel do SO: panic_on_oops ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             1             1             1             aprovado    
    ol9n2             1             1             1             aprovado    
    Parâmetro de Kernel do SO: panic_on_oops ...APROVADO
    Parâmetro de Kernel do SO: kernel.panic ...
    Nome do Nó        Atual         Configurado   Necessário    Status        Comentário  
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n1             10            10            at least 1    aprovado    
    ol9n2             10            10            at least 1    aprovado    
    Parâmetro de Kernel do SO: kernel.panic ...APROVADO
    Pacote: kmod-20-21 (x86_64) ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         kmod(x86_64)-28-10.0.1.el9  kmod(x86_64)-20-21        aprovado  
    ol9n1         kmod(x86_64)-28-10.0.1.el9  kmod(x86_64)-20-21        aprovado  
    Pacote: kmod-20-21 (x86_64) ...APROVADO
    Pacote: kmod-libs-20-21 (x86_64) ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         kmod-libs(x86_64)-28-10.0.1.el9  kmod-libs(x86_64)-20-21   aprovado  
    ol9n1         kmod-libs(x86_64)-28-10.0.1.el9  kmod-libs(x86_64)-20-21   aprovado  
    Pacote: kmod-libs-20-21 (x86_64) ...APROVADO
    Pacote: binutils-2.35.2 ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         binutils-2.35.2-54.0.1.el9  binutils-2.35.2           aprovado  
    ol9n1         binutils-2.35.2-54.0.1.el9  binutils-2.35.2           aprovado  
    Pacote: binutils-2.35.2 ...APROVADO
    Pacote: fontconfig-2.14.0 (x86_64) ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         fontconfig(x86_64)-2.14.0-2.el9_1  fontconfig(x86_64)-2.14.0  aprovado  
    ol9n1         fontconfig(x86_64)-2.14.0-2.el9_1  fontconfig(x86_64)-2.14.0  aprovado  
    Pacote: fontconfig-2.14.0 (x86_64) ...APROVADO
    Pacote: libxcrypt-compat-4.4.18 ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         libxcrypt-compat-4.4.18-3.el9  libxcrypt-compat-4.4.18   aprovado  
    ol9n1         libxcrypt-compat-4.4.18-3.el9  libxcrypt-compat-4.4.18   aprovado  
    Pacote: libxcrypt-compat-4.4.18 ...APROVADO
    Pacote: libgcc-11.3.1 (x86_64) ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         libgcc(x86_64)-11.5.0-2.0.1.el9  libgcc(x86_64)-11.3.1     aprovado  
    ol9n1         libgcc(x86_64)-11.5.0-2.0.1.el9  libgcc(x86_64)-11.3.1     aprovado  
    Pacote: libgcc-11.3.1 (x86_64) ...APROVADO
    Pacote: libstdc++-11.3.1 (x86_64) ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         libstdc++(x86_64)-11.5.0-2.0.1.el9  libstdc++(x86_64)-11.3.1  aprovado  
    ol9n1         libstdc++(x86_64)-11.5.0-2.0.1.el9  libstdc++(x86_64)-11.3.1  aprovado  
    Pacote: libstdc++-11.3.1 (x86_64) ...APROVADO
    Pacote: sysstat-12.5.4 ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         sysstat-12.5.4-9.0.2.el9  sysstat-12.5.4            aprovado  
    ol9n1         sysstat-12.5.4-9.0.2.el9  sysstat-12.5.4            aprovado  
    Pacote: sysstat-12.5.4 ...APROVADO
    Pacote: ksh ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         ksh                       ksh                       aprovado  
    ol9n1         ksh                       ksh                       aprovado  
    Pacote: ksh ...APROVADO
    Pacote: make-4.3 ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         make-4.3-8.el9            make-4.3                  aprovado  
    ol9n1         make-4.3-8.el9            make-4.3                  aprovado  
    Pacote: make-4.3 ...APROVADO
    Pacote: glibc-2.34 (x86_64) ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         glibc(x86_64)-2.34-125.0.1.el9_5.1  glibc(x86_64)-2.34        aprovado  
    ol9n1         glibc(x86_64)-2.34-125.0.1.el9_5.1  glibc(x86_64)-2.34        aprovado  
    Pacote: glibc-2.34 (x86_64) ...APROVADO
    Pacote: glibc-devel-2.34 (x86_64) ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         glibc-devel(x86_64)-2.34-125.0.1.el9_5.1  glibc-devel(x86_64)-2.34  aprovado  
    ol9n1         glibc-devel(x86_64)-2.34-125.0.1.el9_5.1  glibc-devel(x86_64)-2.34  aprovado  
    Pacote: glibc-devel-2.34 (x86_64) ...APROVADO
    Pacote: libaio-0.3.111 (x86_64) ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         libaio(x86_64)-0.3.111-13.el9  libaio(x86_64)-0.3.111    aprovado  
    ol9n1         libaio(x86_64)-0.3.111-13.el9  libaio(x86_64)-0.3.111    aprovado  
    Pacote: libaio-0.3.111 (x86_64) ...APROVADO
    Pacote: nfs-utils-2.5.4 ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         nfs-utils-2.5.4-27.0.1.el9  nfs-utils-2.5.4           aprovado  
    ol9n1         nfs-utils-2.5.4-27.0.1.el9  nfs-utils-2.5.4           aprovado  
    Pacote: nfs-utils-2.5.4 ...APROVADO
    Pacote: smartmontools-7.2-6 ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         smartmontools-7.2-9.el9   smartmontools-7.2-6       aprovado  
    ol9n1         smartmontools-7.2-9.el9   smartmontools-7.2-6       aprovado  
    Pacote: smartmontools-7.2-6 ...APROVADO
    Pacote: net-tools-2.0-0.62 ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         net-tools-2.0-0.64.20160912git.el9  net-tools-2.0-0.62        aprovado  
    ol9n1         net-tools-2.0-0.64.20160912git.el9  net-tools-2.0-0.62        aprovado  
    Pacote: net-tools-2.0-0.62 ...APROVADO
    Pacote: policycoreutils-3.5-1 ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         policycoreutils-3.6-2.1.el9  policycoreutils-3.5-1     aprovado  
    ol9n1         policycoreutils-3.6-2.1.el9  policycoreutils-3.5-1     aprovado  
    Pacote: policycoreutils-3.5-1 ...APROVADO
    Pacote: policycoreutils-python-utils-3.5-1 ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         policycoreutils-python-utils-3.6-2.1.el9  policycoreutils-python-utils-3.5-1  aprovado  
    ol9n1         policycoreutils-python-utils-3.6-2.1.el9  policycoreutils-python-utils-3.5-1  aprovado  
    Pacote: policycoreutils-python-utils-3.5-1 ...APROVADO
    Usuários com o Mesmo UID: 0 ...APROVADO
    ID do Grupo Atual ...APROVADO
    Consistência de usuário-raiz ...
    Nome do Nó                            Status                  
    ------------------------------------  ------------------------
    ol9n2                                 aprovado                
    ol9n1                                 aprovado                
    Consistência de usuário-raiz ...APROVADO
    Pacote: psmisc-22.6-19 ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         psmisc-23.4-3.el9         psmisc-22.6-19            aprovado  
    ol9n1         psmisc-23.4-3.el9         psmisc-22.6-19            aprovado  
    Pacote: psmisc-22.6-19 ...APROVADO
    Nome do host ...APROVADO
    Conectividade de Nó ...
    Arquivo dos Hosts ...
    Nome do Nó                            Status                  
    ------------------------------------  ------------------------
    ol9n1                                 aprovado                
    ol9n2                                 aprovado                
    Arquivo dos Hosts ...APROVADO
    Informações de interface para o nó "ol9n1"

    Nome   Endereço IP     Sub-rede        Gateway         Gateway Def.    Endereço HW       MTU   
    ------ --------------- --------------- --------------- --------------- ----------------- ------
    enp1s0 192.168.18.121  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:28:86:AA 1500  
    enp3s0 192.168.100.101 192.168.100.0   0.0.0.0         192.168.100.1   52:54:00:7F:44:40 1500  
    
    Informações de interface para o nó "ol9n2"
    Nome   Endereço IP     Sub-rede        Gateway         Gateway Def.    Endereço HW       MTU   
    ------ --------------- --------------- --------------- --------------- ----------------- ------
    enp1s0 192.168.18.122  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:6B:00:2D 1500  
    enp3s0 192.168.100.102 192.168.100.0   0.0.0.0         192.168.100.1   52:54:00:5D:35:1F 1500  
    
    Verificar: Consistência de MTU da sub-rede "192.168.18.0".
    Nó                Nome          Endereço IP   Sub-rede      MTU             
    ----------------  ------------  ------------  ------------  ----------------
    ol9n1             enp1s0        192.168.18.121  192.168.18.0  1500            
    ol9n2             enp1s0        192.168.18.122  192.168.18.0  1500            
    
    Verificar: Consistência de MTU da sub-rede "192.168.100.0".
    Nó                Nome          Endereço IP   Sub-rede      MTU             
    ----------------  ------------  ------------  ------------  ----------------
    ol9n1             enp3s0        192.168.100.101  192.168.100.0  1500            
    ol9n2             enp3s0        192.168.100.102  192.168.100.0  1500            

    Origem                      Destino                     Conectado?                
    --------------------------  --------------------------  --------------------------
    ol9n1[enp1s0:192.168.18.121]  ol9n2[enp1s0:192.168.18.122]  sim                       

    Origem                      Destino                     Conectado?                
    --------------------------  --------------------------  --------------------------
    ol9n1[enp3s0:192.168.100.101]  ol9n2[enp3s0:192.168.100.102]  sim                       
    Verifique se o tamanho máximo (MTU) do pacote passa pela sub-rede ...APROVADO
    consistência de máscara para a sub-rede "192.168.18.0" ...APROVADO
    consistência de máscara para a sub-rede "192.168.100.0" ...APROVADO
    Conectividade de Nó ...APROVADO
    Verificação de multicast ou broadcast ...    
    Verificando sub-rede "192.168.18.0" para comunicação multicast com o grupo multicast "224.0.0.251"
    Verificação de multicast ou broadcast ...APROVADO
    Verificação da instalação e da configuração de ASMLib ...
    '/etc/init.d/oracleasm' ...APROVADO
    '/dev/oracleasm' ...APROVADO

    Nome do Nó                            Status                  
    ------------------------------------  ------------------------
    ol9n1                                 aprovado                
    ol9n2                                 aprovado                
    Verificação da instalação e da configuração de ASMLib ...APROVADO
    NTP (Network Time Protocol) ...
    Daemon 'chronyd' ...
    Nome do Nó                            Em execução?            
    ------------------------------------  ------------------------
    ol9n2                                 sim                     
    ol9n1                                 sim                     

    Daemon 'chronyd' ...APROVADO
    Daemon ou serviço NTP usando a porta UDP 123 ...
    Nome do Nó                            Porta Aberta?           
    ------------------------------------  ------------------------
    ol9n2                                 sim                     
    ol9n1                                 sim                     

    Daemon ou serviço NTP usando a porta UDP 123 ...APROVADO
    O daemon chrony está sincronizado com pelo menos uma origem de tempo externa ...APROVADO
    NTP (Network Time Protocol) ...APROVADO
    Padrão do nome do arquivo central igual ...APROVADO
    Máscara do Usuário ...
    Nome do Nó    Disponível                Necessário                Comentário
    ------------  ------------------------  ------------------------  ----------
    ol9n2         0022                      0022                      aprovado  
    ol9n1         0022                      0022                      aprovado  
    Máscara do Usuário ...APROVADO
    O Usuário Não Está no Grupo "root": grid ...
    Nome do Nó    Status                    Comentário              
    ------------  ------------------------  ------------------------
    ol9n2         aprovado                  não existe              
    ol9n1         aprovado                  não existe              
    O Usuário Não Está no Grupo "root": grid ...APROVADO
    Consistência do fuso horário ...APROVADO
    Path existence, ownership, permissions and attributes ...
    Path "/var" ...APROVADO
    Path "/dev/shm" ...APROVADO
    Path existence, ownership, permissions and attributes ...APROVADO
    Diferença de horário entre os nós ...APROVADO
    Integridade de resolv.conf ...
    Nome do Nó                            Status                  
    ------------------------------------  ------------------------
    ol9n1                                 aprovado                
    ol9n2                                 aprovado                
    
    verificando resposta para o nome "ol9n2" de cada um dos servidores de nome
    especificados em "/etc/resolv.conf"

    Nome do Nó    Origem                    Comentário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         192.168.18.201            IPv4                      aprovado  
    
    verificando resposta para o nome "ol9n1" de cada um dos servidores de nome especificados em "/etc/resolv.conf"

    Nome do Nó    Origem                    Comentário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n1         192.168.18.201            IPv4                      aprovado  
    Integridade de resolv.conf ...APROVADO
    Serviço do nome DNS/NIS ...APROVADO
    O daemon "avahi-daemon" não está configurado e em execução ...
    Nome do Nó    Configurado               Status                  
    ------------  ------------------------  ------------------------
    ol9n2         não                       aprovado                
    ol9n1         não                       aprovado                

    Nome do Nó    Em execução?              Status                  
    ------------  ------------------------  ------------------------
    ol9n2         não                       aprovado                
    ol9n1         não                       aprovado                
    O daemon "avahi-daemon" não está configurado e em execução ...APROVADO
    O daemon "proxyt" não está configurado e em execução ...
    Nome do Nó    Configurado               Status                  
    ------------  ------------------------  ------------------------
    ol9n2         não                       aprovado                
    ol9n1         não                       aprovado                

    Nome do Nó    Em execução?              Status                  
    ------------  ------------------------  ------------------------
    ol9n2         não                       aprovado                
    ol9n1         não                       aprovado                
    O daemon "proxyt" não está configurado e em execução ...APROVADO
    Soquetes do domínio ...APROVADO
    Equivalência de Usuário ...APROVADO
    Banco de dados do Gerenciador de Pacotes do RPM ...APROVADO
    Verificação de máximo de memória bloqueada ...APROVADO
    /dev/shm montado como sistema de arquivos temporários ...APROVADO
    Opção de montagem do sistema de arquivos hidepid para o sistema de arquivos proc ...APROVADO
    Configuração do Driver de Filtro do ASM ...APROVADO
    Parâmetro IPC do gerenciador de log-in no systemd ...APROVADO
    ORAchk health score ...INFORMAÇÕES (PRVH-1507)

    A pré-verificação de configuração de serviços de cluster foi bem-sucedida. 
    ORAchk health score ...INFORMAÇÕES
    PRVH-1507 : ORAchk/EXAchk checks are skipped.


    Operação do CVU executada:    stage -pre crsinst
    Data:                         28 de fev de 2025 16:45:22
    Versão do CVU:                23.7.0.25.1 (011525x8664)
    Home do CVU:                  /u01/app/23.7.0/grid
    Usuário:                      grid
    Sistema operacional:          Linux5.15.0-302.167.6.el9uek.x86_64

###### CLUSTER INSTALL ( SET EXADATA PARAMETER )

    [root@ol9n1 ~]# cat /u01/app/23.7.0/grid/crs/install/crsconfig_params |grep ASMCA_ARGS
    ASMCA_ARGS=
    [root@ol9n1 ~]# su - grid
    [grid@ol9n1 ~]$ vi /u01/app/23.7.0/grid/crs/install/crsconfig_params
    ASMCA_ARGS=-param "_exadata_feature_on=true"
    [grid@ol9n1 ~]$ exit

    [root@ol9n2 ~]# cat /u01/app/23.7.0/grid/crs/install/crsconfig_params |grep ASMCA_ARGS 
    ASMCA_ARGS=
    [root@ol9n2 ~]# su - grid
    [grid@ol9n2 ~]$ vi /u01/app/23.7.0/grid/crs/install/crsconfig_params 
    ASMCA_ARGS=-param "_exadata_feature_on=true"
    [grid@ol9n2 ~]$ exit

###### POST INSTALL CHECK ENVIRONMENT ( RUNCLUVFY )


    [root@ol9n1 ~]# su - grid
    [grid@ol9n1 ~]$ /u01/app/23.7.0/grid/runcluvfy.sh stage -post crsinst -n ol9n1,ol9n2 -verbose -method root
    Digite a senha de "ROOT":

    Initializing ...

    Performing following verification checks ...

    Conectividade de Nó ...
    Arquivo dos Hosts ...
    Nome do Nó                            Status                  
    ------------------------------------  ------------------------
    ol9n1                                 aprovado                
    ol9n2                                 aprovado                
    Arquivo dos Hosts ...APROVADO

    Informações de interface para o nó "ol9n1"

    Nome   Endereço IP     Sub-rede        Gateway         Gateway Def.    Endereço HW       MTU   
    ------ --------------- --------------- --------------- --------------- ----------------- ------
    enp1s0 192.168.18.121  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:28:86:AA 1500  
    enp1s0 192.168.18.185  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:28:86:AA 1500  
    enp1s0 192.168.18.151  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:28:86:AA 1500  
    enp1s0 192.168.18.184  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:28:86:AA 1500  
    enp1s0 192.168.18.187  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:28:86:AA 1500  
    enp3s0 192.168.100.101 192.168.100.0   0.0.0.0         192.168.100.1   52:54:00:7F:44:40 1500  

    Informações de interface para o nó "ol9n2"

    Nome   Endereço IP     Sub-rede        Gateway         Gateway Def.    Endereço HW       MTU   
    ------ --------------- --------------- --------------- --------------- ----------------- ------
    enp1s0 192.168.18.122  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:6B:00:2D 1500  
    enp1s0 192.168.18.152  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:6B:00:2D 1500  
    enp1s0 192.168.18.186  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:6B:00:2D 1500  
    enp3s0 192.168.100.102 192.168.100.0   0.0.0.0         192.168.100.1   52:54:00:5D:35:1F 1500  
    
    Verificar: Consistência de MTU das interfaces privadas da sub-rede "192.168.100.0"

    Nó                Nome          Endereço IP   Sub-rede      MTU             
    ----------------  ------------  ------------  ------------  ----------------
    ol9n1             enp3s0        192.168.100.101  192.168.100.0  1500            
    ol9n2             enp3s0        192.168.100.102  192.168.100.0  1500            

    Verificar: Consistência de MTU da sub-rede "192.168.18.0".

    Nó                Nome          Endereço IP   Sub-rede      MTU             
    ----------------  ------------  ------------  ------------  ----------------
    ol9n1             enp1s0        192.168.18.121  192.168.18.0  1500            
    ol9n1             enp1s0        192.168.18.185  192.168.18.0  1500            
    ol9n1             enp1s0        192.168.18.151  192.168.18.0  1500            
    ol9n1             enp1s0        192.168.18.184  192.168.18.0  1500            
    ol9n1             enp1s0        192.168.18.187  192.168.18.0  1500            
    ol9n2             enp1s0        192.168.18.122  192.168.18.0  1500            
    ol9n2             enp1s0        192.168.18.152  192.168.18.0  1500            
    ol9n2             enp1s0        192.168.18.186  192.168.18.0  1500            

    Origem                      Destino                     Conectado?                
    --------------------------  --------------------------  --------------------------
    ol9n1[enp1s0:192.168.18.121]  ol9n2[enp1s0:192.168.18.122]  sim                       
    ol9n1[enp1s0:192.168.18.121]  ol9n2[enp1s0:192.168.18.152]  sim                       
    ol9n1[enp1s0:192.168.18.121]  ol9n2[enp1s0:192.168.18.186]  sim                       
    ol9n1[enp1s0:192.168.18.185]  ol9n2[enp1s0:192.168.18.122]  sim                       
    ol9n1[enp1s0:192.168.18.185]  ol9n2[enp1s0:192.168.18.152]  sim                       
    ol9n1[enp1s0:192.168.18.185]  ol9n2[enp1s0:192.168.18.186]  sim                       
    ol9n1[enp1s0:192.168.18.151]  ol9n2[enp1s0:192.168.18.122]  sim                       
    ol9n1[enp1s0:192.168.18.151]  ol9n2[enp1s0:192.168.18.152]  sim                       
    ol9n1[enp1s0:192.168.18.151]  ol9n2[enp1s0:192.168.18.186]  sim                       
    ol9n1[enp1s0:192.168.18.184]  ol9n2[enp1s0:192.168.18.122]  sim                       
    ol9n1[enp1s0:192.168.18.184]  ol9n2[enp1s0:192.168.18.152]  sim                       
    ol9n1[enp1s0:192.168.18.184]  ol9n2[enp1s0:192.168.18.186]  sim                       
    ol9n1[enp1s0:192.168.18.187]  ol9n2[enp1s0:192.168.18.122]  sim                       
    ol9n1[enp1s0:192.168.18.187]  ol9n2[enp1s0:192.168.18.152]  sim                       
    ol9n1[enp1s0:192.168.18.187]  ol9n2[enp1s0:192.168.18.186]  sim                       

    Origem                      Destino                     Conectado?                
    --------------------------  --------------------------  --------------------------
    ol9n1[enp3s0:192.168.100.101]  ol9n2[enp3s0:192.168.100.102]  sim                       

    Origem                      Destino                     Conectado?                
    --------------------------  --------------------------  --------------------------
    ol9n1[enp3s0:169.254.6.91]  ol9n2[enp3s0:169.254.9.106]  sim                       
    Verifique se o tamanho máximo (MTU) do pacote passa pela sub-rede ...APROVADO
    consistência de máscara para a sub-rede "192.168.18.0" ...APROVADO
    consistência de máscara para a sub-rede "192.168.100.0" ...APROVADO
    Conectividade de Nó ...APROVADO
    Verificação de multicast ou broadcast ...    
    Verificando sub-rede "192.168.100.0" para comunicação multicast com o grupo multicast "224.0.0.251"
    Verificação de multicast ou broadcast ...APROVADO
    Consistência do fuso horário ...APROVADO
    Vendor cluster check ...APROVADO
    Path existence, ownership, permissions and attributes ...
    Path "/var" ...APROVADO
    Path "/var/lib/oracle" ...APROVADO
    Path "/u01/app/oraInventory/ContentsXML/inventory.xml" ...APROVADO
    Path "/dev/asm" ...APROVADO
    Path "/dev/shm" ...APROVADO
    Path "/etc/init.d/ohasd" ...APROVADO
    Path "/etc/init.d/init.ohasd" ...APROVADO
    Path "/etc/init.d/init.tfa" ...APROVADO
    Path "/etc/oracle/maps" ...APROVADO
    Path "/etc/oraInst.loc" ...APROVADO
    Path "/etc/tmpfiles.d/oracleGI.conf" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol9n1/crs/metadata" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol9n1/crs/lck" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol9n1/crs/log" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol9n1/crs/trace" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol9n1/crs/cdump" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol9n1/crs/metadata_pv" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol9n1/crs/alert" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol9n1/crs/sweep" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol9n1/crs/stage" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol9n1/crs/metadata_dgif" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol9n1/crs/incpkg" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol9n1/crs/incident" ...APROVADO
    Path "/u01/app/23.7.0/grid/gpnp/wallets/peer/cwallet.sso" ...APROVADO
    Path "/u01/app/23.7.0/grid/gpnp/wallets/root/ewallet.p12" ...APROVADO
    Path "/u01/app/23.7.0/grid/gpnp/profiles/peer/profile.xml" ...APROVADO
    Path existence, ownership, permissions and attributes ...APROVADO
    Integridade de Gerenciador de Cluster ...
    Nome do Nó                            Status                  
    ------------------------------------  ------------------------
    ol9n1                                 em execução             
    ol9n2                                 em execução             
    Integridade de Gerenciador de Cluster ...APROVADO
    Máscara do Usuário ...
    Nome do Nó    Disponível                Necessário                Comentário
    ------------  ------------------------  ------------------------  ----------
    ol9n2         0022                      0022                      aprovado  
    ol9n1         0022                      0022                      aprovado  
    Máscara do Usuário ...APROVADO
    Integridade de Cluster ...
    Nome do Nó                          
    ------------------------------------
    ol9n1                               
    ol9n2                               
    Integridade de Cluster ...APROVADO
    Integridade do OCR ...APROVADO
    Integridade CRS ...
    Consistência da Versão do Clusterware ...APROVADO
    Integridade CRS ...APROVADO
    Existência de Aplicativo de Nó ...
    
    Verificando a existência do aplicativo de nó VIP (obrigatório)

    Nome do Nó    Necessário                Em execução?              Comentário
    ------------  ------------------------  ------------------------  ----------
    ol9n1         sim                       sim                       aprovado  
    ol9n2         sim                       sim                       aprovado  

    Verificando a existência do aplicativo de nó NETWORK (obrigatório)

    Nome do Nó    Necessário                Em execução?              Comentário
    ------------  ------------------------  ------------------------  ----------
    ol9n1         sim                       sim                       aprovado  
    ol9n2         sim                       sim                       aprovado  

    Verificando a existência do aplicativo de nó ONS (opcional)

    Nome do Nó    Necessário                Em execução?              Comentário
    ------------  ------------------------  ------------------------  ----------
    ol9n1         não                       sim                       aprovado  
    ol9n2         não                       sim                       aprovado  
    
    Existência de Aplicativo de Nó ...APROVADO
    SCAN ("Single Client Access Name", Nome de Acesso de Cliente Único) ...
    Nome do SCAN      Nó            Em execução?  ListenerName  Porta         Em execução?
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n-scan         ol9n1         true          LISTENER_SCAN1  1521          true        
    ol9n-scan         ol9n1         true          LISTENER_SCAN2  1521          true        
    ol9n-scan         ol9n1         true          LISTENER_SCAN3  1521          true        
    ol9n-scan         ol9n2         true          LISTENER_SCAN4  1521          true        

    Verificando a conectividade TCP com os listeners SCAN...

    Nó            ListenerName              Conectividade do TCP?   
    ------------  ------------------------  ------------------------
    ol9n1         LISTENER_SCAN1            sim                     
    ol9n1         LISTENER_SCAN2            sim                     
    ol9n1         LISTENER_SCAN3            sim                     
    ol9n1         LISTENER_SCAN4            sim                     

    Serviço do nome DNS/NIS 'ol9n-scan' ...
      Integridade do Arquivo de Configuração da Switch do Serviço de Nome ...APROVADO

    Nome do SCAN  Endereço IP               Status                    Comentário
    ------------  ------------------------  ------------------------  ----------
    ol9n-scan     192.168.18.184            aprovado                            
    ol9n-scan     192.168.18.186            aprovado                            
    ol9n-scan     192.168.18.185            aprovado                            
    ol9n-scan     192.168.18.187            aprovado                            
    Serviço do nome DNS/NIS 'ol9n-scan' ...APROVADO
    
    SCAN ("Single Client Access Name", Nome de Acesso de Cliente Único) ...APROVADO
    Integridade de OLR ...APROVADO
    Voting Disk ...APROVADO
    Integridade de ASM ...
    Nó                                    Em execução?            
    ------------------------------------  ------------------------
    ol9n1                                 sim                     
    ol9n2                                 sim                     
  
    Integridade de ASM ...APROVADO
    ASM Network ...APROVADO
    Espaço livre do grupo de discos do ASM ...APROVADO
    O Usuário Não Está no Grupo "root": grid ...
    Nome do Nó    Status                    Comentário              
    ------------  ------------------------  ------------------------
    ol9n2         aprovado                  não existe              
    ol9n1         aprovado                  não existe              
  
    O Usuário Não Está no Grupo "root": grid ...APROVADO
    Sincronização do Relógio ...
    NTP (Network Time Protocol) ...
    Daemon 'chronyd' ...
    Nome do Nó                            Em execução?            
    ------------------------------------  ------------------------
    ol9n2                                 sim                     
    ol9n1                                 sim                     

    Daemon 'chronyd' ...APROVADO
    Daemon ou serviço NTP usando a porta UDP 123 ...
    Nome do Nó                            Porta Aberta?           
    ------------------------------------  ------------------------
    ol9n2                                 sim                     
    ol9n1                                 sim                     

    Daemon ou serviço NTP usando a porta UDP 123 ...APROVADO
    O daemon chrony está sincronizado com pelo menos uma origem de tempo externa ...APROVADO
    NTP (Network Time Protocol) ...APROVADO
    Sincronização do Relógio ...APROVADO
    Verificação da configuração de sub-rede VIP ...APROVADO
    Oracle Net Services configuration ...APROVADO
    
    Verificações de consistência de configuração de rede ...APROVADO
    Pacote: psmisc-22.6-19 ...
    Nome do Nó    Disponível                Necessário                Status    
    ------------  ------------------------  ------------------------  ----------
    ol9n2         psmisc-23.4-3.el9         psmisc-22.6-19            aprovado  
    ol9n1         psmisc-23.4-3.el9         psmisc-22.6-19            aprovado  
    Pacote: psmisc-22.6-19 ...APROVADO
  
    Opções de montagem do sistema de arquivos para o caminho GI_HOME ...APROVADO
    Opção de montagem do sistema de arquivos hidepid para o sistema de arquivos proc ...APROVADO
    Limpeza de arquivos socket de comunicação ...APROVADO
    Soquetes do domínio ...APROVADO
    ORAchk health score ...

    CSS reboot time ...APROVADO
    Verify clusterware internal patch metadata matches grid home OPatch inventory ...APROVADO
    GI/CRS - Private interconnect interface name check ...APROVADO
    TFA Collector status ...APROVADO
    VIP NIC bonding config. ...APROVADO
    Verify Cluster health Monitor(CHM) configuration ...APROVADO
    Clusterware version comparison ...APROVADO
    Clusterware software version comparison ...APROVADO
    Verify / at the end of ORACLE_HOME ...APROVADO
    HAIP and Bonded interface ...APROVADO
    RAC interconnect network card speed ...APROVADO
    Operating System Version comparison ...APROVADO
    Root  time zone ...APROVADO
    Verify Cluster health analyzer (CHA)  configuration ...APROVADO
    Public interface existence ...APROVADO
    Verify private and public network subnet configuration in Oracle Clusterware registry ...APROVADO
    Check the integrity of key GI startup files ...APROVADO
    CSS log file size ...APROVADO
    CSS disktimeout ...APROVADO
    Old log files in client directory in crs_home ...APROVADO
    3rd Party Clusterware Node Numbering ...APROVADO
    Non-routable network for interconnect ...APROVADO
    Jumbo frames configuration for interconnect ...APROVADO
    Verify Cluster Synchronization Services (CSS) misscount value ...APROVADO
    Verify CRS Attribute RESOURCE_USE_ENABLED ...APROVADO
    Hang and Deadlock material ...APROVADO
    GI/CRS software owner across cluster ...APROVADO
    Verify online (hot) patches are not applied on CRS_HOME ...APROVADO
    ORAchk health score 91% ...APROVADO

    A pós-verificação de configuração de serviços de cluster foi bem-sucedida. 

    Operação do CVU executada:    stage -post crsinst
    Data:                         1 de mar de 2025 22:09:30
    Versão do CVU:                23.7.0.25.1 (011525x8664)
    Versão do Clusterware:        23.0.0.0.0
    Home do CVU:                  /u01/app/23.7.0/grid
    Home do Grid:                 /u01/app/23.7.0/grid
    Usuário:                      grid
    Sistema operacional:          Linux5.15.0-302.167.6.el9uek.x86_64
    [grid@ol9n1 ~]$ exit

###### CHECK CLUSTER STATUS ( CRSCTL )

    [grid@ol9n1 ~]$ /u01/app/23.7.0/grid/bin/crsctl check cluster -all
    **************************************************************
    ol9n1:
    CRS-4537: Cluster Ready Services is online
    CRS-4529: Cluster Synchronization Services is online
    CRS-4533: Event Manager is online
    **************************************************************
    ol9n2:
    CRS-4537: Cluster Ready Services is online
    CRS-4529: Cluster Synchronization Services is online
    CRS-4533: Event Manager is online
    **************************************************************

    [grid@ol9n1 ~]$ /u01/app/23.7.0/grid/bin/crsctl stat res -t 
    --------------------------------------------------------------------------------
    Name           Target  State        Server                   State details       
    --------------------------------------------------------------------------------
    Local Resources
    --------------------------------------------------------------------------------
    ora.LISTENER.lsnr
               ONLINE  ONLINE       ol9n1                    STABLE
               ONLINE  ONLINE       ol9n2                    STABLE
    ora.chad
               ONLINE  ONLINE       ol9n1                    STABLE
               ONLINE  ONLINE       ol9n2                    STABLE
    ora.helper
               OFFLINE OFFLINE      ol9n1                    STABLE
               OFFLINE OFFLINE      ol9n2                    IDLE,STABLE
    ora.net1.network
               ONLINE  ONLINE       ol9n1                    STABLE
               ONLINE  ONLINE       ol9n2                    STABLE
    ora.ons
               ONLINE  ONLINE       ol9n1                    STABLE
               ONLINE  ONLINE       ol9n2                    STABLE
    --------------------------------------------------------------------------------
    Cluster Resources
    --------------------------------------------------------------------------------
    ora.ASMNET1LSNR_ASM.lsnr(ora.asmgroup)
      1        ONLINE  ONLINE       ol9n1                    STABLE
      2        ONLINE  ONLINE       ol9n2                    STABLE
    ora.DATA.dg(ora.asmgroup)
      1        ONLINE  ONLINE       ol9n1                    STABLE
      2        ONLINE  ONLINE       ol9n2                    STABLE
    ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       ol9n1                    STABLE
    ora.LISTENER_SCAN2.lsnr
      1        ONLINE  ONLINE       ol9n1                    STABLE
    ora.LISTENER_SCAN3.lsnr
      1        ONLINE  ONLINE       ol9n1                    STABLE
    ora.LISTENER_SCAN4.lsnr
      1        ONLINE  ONLINE       ol9n2                    STABLE
    ora.asm(ora.asmgroup)
      1        ONLINE  ONLINE       ol9n1                    Started,STABLE
      2        ONLINE  ONLINE       ol9n2                    Started,STABLE
    ora.asmnet1.asmnetwork(ora.asmgroup)
      1        ONLINE  ONLINE       ol9n1                    STABLE
      2        ONLINE  ONLINE       ol9n2                    STABLE
    ora.cdp1.cdp
      1        ONLINE  ONLINE       ol9n1                    STABLE
    ora.cdp2.cdp
      1        ONLINE  ONLINE       ol9n1                    STABLE
    ora.cdp3.cdp
      1        ONLINE  ONLINE       ol9n1                    STABLE
    ora.cdp4.cdp
      1        ONLINE  ONLINE       ol9n2                    STABLE
    ora.cvu
      1        ONLINE  ONLINE       ol9n1                    STABLE
    ora.ol9n1.vip
      1        ONLINE  ONLINE       ol9n1                    STABLE
    ora.ol9n2.vip
      1        ONLINE  ONLINE       ol9n2                    STABLE
    ora.rhpserver
      1        OFFLINE OFFLINE                               STABLE
    ora.scan1.vip
      1        ONLINE  ONLINE       ol9n1                    STABLE
    ora.scan2.vip
      1        ONLINE  ONLINE       ol9n1                    STABLE
    ora.scan3.vip
      1        ONLINE  ONLINE       ol9n1                    STABLE
    ora.scan4.vip
      1        ONLINE  ONLINE       ol9n2                    STABLE
    --------------------------------------------------------------------------------
    [grid@ol9n1 ~]$ exit

    [root@ol9n1 ~]# export ORACLE_HOME=/u01/app/23.7.0/grid
    [root@ol9n1 ~]# export PATH=$PATH:$ORACLE_HOME/bin
    [root@ol9n1 ~]# crsctl status resource
    NAME=ora.ASMNET1LSNR_ASM.lsnr(ora.asmgroup)
    TYPE=ora.asm_listener.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol9n1, ONLINE on ol9n2

    NAME=ora.DATA.dg(ora.asmgroup)
    TYPE=ora.diskgroup.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol9n1, ONLINE on ol9n2

    NAME=ora.LISTENER.lsnr
    TYPE=ora.listener.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol9n1, ONLINE on ol9n2

    NAME=ora.LISTENER_SCAN1.lsnr
    TYPE=ora.scan_listener.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n1

    NAME=ora.LISTENER_SCAN2.lsnr
    TYPE=ora.scan_listener.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n1

    NAME=ora.LISTENER_SCAN3.lsnr
    TYPE=ora.scan_listener.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n1

    NAME=ora.LISTENER_SCAN4.lsnr
    TYPE=ora.scan_listener.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n2

    NAME=ora.asm(ora.asmgroup)
    TYPE=ora.asm.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol9n1, ONLINE on ol9n2

    NAME=ora.asmnet1.asmnetwork(ora.asmgroup)
    TYPE=ora.asm_network.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol9n1, ONLINE on ol9n2

    NAME=ora.cdp1.cdp
    TYPE=ora.cdp.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n1

    NAME=ora.cdp2.cdp
    TYPE=ora.cdp.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n1

    NAME=ora.cdp3.cdp
    TYPE=ora.cdp.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n1

    NAME=ora.cdp4.cdp
    TYPE=ora.cdp.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n2

    NAME=ora.chad
    TYPE=ora.chad.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol9n1, ONLINE on ol9n2

    NAME=ora.cvu
    TYPE=ora.cvu.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n1

    NAME=ora.helper
    TYPE=ora.helper.type
    TARGET=OFFLINE, OFFLINE
    STATE=OFFLINE, OFFLINE

    NAME=ora.net1.network
    TYPE=ora.network.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol9n1, ONLINE on ol9n2

    NAME=ora.ol9n1.vip
    TYPE=ora.cluster_vip_net1.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n1

    NAME=ora.ol9n2.vip
    TYPE=ora.cluster_vip_net1.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n2

    NAME=ora.ons
    TYPE=ora.ons.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol9n1, ONLINE on ol9n2

    NAME=ora.rhpserver
    TYPE=ora.rhpserver.type
    TARGET=OFFLINE
    STATE=OFFLINE

    NAME=ora.scan1.vip
    TYPE=ora.scan_vip.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n1

    NAME=ora.scan2.vip
    TYPE=ora.scan_vip.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n1

    NAME=ora.scan3.vip
    TYPE=ora.scan_vip.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n1

    NAME=ora.scan4.vip
    TYPE=ora.scan_vip.type
    TARGET=ONLINE
    STATE=ONLINE on ol9n2

###### COPY GRID INFRASTRUCTURE SOFTWARE

    [root@exated Downloads]# scp p37370465_230000_Linux-x86-64.zip oracle@192.168.18.121:/u01/app/oracle/product/23.7.0/dbhome_1/

###### UNZIP GRID INFRASTRUCTURE SOFTWARE

    [root@ol9n1 ~]# su - oracle
    [oracle@ol9n1 ~]$ cd /u01/app/oracle/product/23.7.0/dbhome_1/
    [oracle@ol9n1 dbhome_1]$ unzip p37370465_230000_Linux-x86-64.zip
    [oracle@ol9n1 dbhome_1]$ rm -vf p37370465_230000_Linux-x86-64.zip
    
###### INSTALL ORACLE DATABASE 23AI SOFTWARE 

    [root@ol9n1 ~]# su - oracle
    [oracle@ol9n1 ~]$ vi /u01/app/oracle/admin/oradbc/pfile/init.ora
    _exadata_feature_on=true




