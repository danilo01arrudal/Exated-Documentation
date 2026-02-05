**ORACLE AI DATABASE 26ai 2 NODE RAC PLUS STORAGE ON OL9.5**

> *The main purpose of installing Oracle RAC is to provide high availability and horizontal scalability for Oracle databases. It allows multiple database instances to operate simultaneously on different servers, sharing the same data store. This ensures that, in the event of a server failure, the database remains accessible without interruption, and also allows processing capacity to be increased by adding new servers. Oracle RAC is ideal for mission-critical applications that require continuous performance and fault tolerance, optimizing resource utilization and improving response to increasing transaction demands.*

![oracle database 26ai logo.](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/oracle_ai_database_26ai_logo.png)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER ol926ain1 

    virt-install --virt-type kvm --name ol926ain1 --memory 8192 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --network bridge=br0,model=virtio --network network=priv0,model=virtio --disk path=/var/lib/libvirt/images/ol926ain1.qcow2,size=59

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER ol926ain2 

    virt-install --virt-type kvm --name ol926ain2 --memory 8192 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --network bridge=br0,model=virtio --network network=priv0,model=virtio --disk path=/var/lib/libvirt/images/ol926ain2.qcow2,size=59

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( DISABLE FIREWALL )

    [root@ol926ain1 ~]# systemctl stop firewalld
    [root@ol926ain1 ~]# systemctl disable firewalld
    [root@ol926ain2 ~]# systemctl stop firewalld
    [root@ol926ain2 ~]# systemctl disable firewalld

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( SET HOSTNAME )

    [root@ol926ain1 ~]# hostnamectl set-hostname ol926ain1.appsdba.info
    [root@ol926ain2 ~]# hostnamectl set-hostname ol926ain2.appsdba.info

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CHANGE THE CLOCK SOURCE IN THE SYSTEM )

    [root@ol926ain1 ~]# cat /sys/devices/system/clocksource/clocksource0/current_clocksource
    kvm-clock
    [root@ol926ain1 ~]# cat /sys/devices/system/clocksource/clocksource0/available_clocksource
    kvm-clock tsc acpi_pm 
    [root@ol926ain1 ~]# echo "tsc" > /sys/devices/system/clocksource/clocksource0/current_clocksource
    tsc
    [root@ol926ain2 ~]# echo "tsc" >  /sys/devices/system/clocksource/clocksource0/current_clocksource
    tsc

###### SET ON /etc/fstab TMPFS PARTITION

    [root@ol926ain1 ~]# vi /etc/fstab
		tmpfs      				  /dev/shm        	  tmpfs   defaults,size=4G	0 0
 
	[root@ol926ain2 ~]# vi /etc/fstab
 		tmpfs      				  /dev/shm        	  tmpfs   defaults,size=4G	0 0

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE STATIC NETWORK NODE 1)

	[root@ol926ain1 ~]# nmcli device
	DEVICE  TYPE      STATE                   CONNECTION 
	enp1s0  ethernet  connected               enp1s0       
	enp3s0  ethernet  connected               enp3s0     
	lo      loopback  connected (externally)  lo      
	[root@ol926ain1 ~]# nmcli connection show 
	NAME  UUID                                  TYPE      DEVICE 
	enp1s0  aa44fa64-eec9-39ef-a6e0-4afc475c1d3d  ethernet  enp1s0   
	enp3s0  ab517c35-fa91-30c4-b092-9dc57355067b  ethernet  enp3s0   
	lo    248fd8c7-0102-4858-93a9-d38d2ea4fd05  loopback  lo
    [root@ol926ain1 ~]# nmcli con modify 'enp1s0' ifname enp1s0 ipv4.method manual ipv4.addresses 192.168.18.121/24 ipv4.gateway 192.168.18.1 autoconnect yes ipv6.method disabled
    [root@ol926ain1 ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.43 
    [root@ol926ain1 ~]# nmcli con down 'enp1s0'; nmcli con up 'ens3'  
	[root@ol926ain1 ~]# ip addr show enp1s0
	2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:85:ab:d0 brd ff:ff:ff:ff:ff:ff
    altname enp1s0
    inet 192.168.18.121/24 brd 192.168.18.255 scope global noprefixroute ens3
       valid_lft forever preferred_lft forever
    [root@ol926ain1 ~]# nmcli con modify 'enp3s0' ifname enp3s0 ipv4.method manual ipv4.addresses 192.168.100.101/24 ipv4.gateway 192.168.100.1 autoconnect yes ipv6.method disabled
    [root@ol926ain1 ~]# nmcli con down 'enp3s0'; nmcli con up 'enp3s0'
	[root@ol926ain1 ~]#  ip addr show enp3s0 
	4: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:2c:ee:2d brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.101/24 brd 192.168.100.255 scope global noprefixroute enp3s0
       valid_lft forever preferred_lft forever
	[root@ol926ain1 ~]# nmcli device
	DEVICE  TYPE      STATE                   CONNECTION 
	enp1s0  ethernet  connected               enp1s0      
	enp3s0  ethernet  connected               enp3s0     
	lo      loopback  connected (externally)  lo         
	[root@ol926ain1 ~]# nmcli connection show 
	NAME    UUID                                  TYPE      DEVICE 
	enp1s0  6b189709-3f1d-3683-bb3d-694e82554e82  ethernet  enp1s0 
	enp3s0  0c094cdd-0d7a-3cbb-a2a2-09e0eaf839e9  ethernet  enp3s0 
	lo      2928747e-520a-4089-9fd3-9f6a56a91144  loopback  lo    

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE STATIC NETWORK NODE 2)

	[root@ol926ain2 ~]# nmcli device
	DEVICE  TYPE      STATE                   CONNECTION 
	enp1s0  ethernet  connected               enp1s0         
	enp3s0  ethernet  connected               enp3s0     
	lo      loopback  connected (externally)  lo      
	[root@ol926ain2 ~]# nmcli connection show 
	NAME  UUID                                  TYPE      DEVICE 
	enp1s0  aa44fa64-eec9-39ef-a6e0-4afc475c1d3d  ethernet  enp1s0     
	enp3s0  ab517c35-fa91-30c4-b092-9dc57355067b  ethernet  enp3s0   
	lo    248fd8c7-0102-4858-93a9-d38d2ea4fd05  loopback  lo
    [root@ol926ain2 ~]# nmcli con modify 'enp1s0' ifname enp1s0 ipv4.method manual ipv4.addresses 192.168.18.122/24 ipv4.gateway 192.168.18.1 autoconnect yes ipv6.method disabled
    [root@ol926ain2 ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.43 
    [root@ol926ain2 ~]# nmcli con down 'enp1s0'; nmcli con up 'ens3'  
	[root@ol926ain2 ~]# ip addr show enp1s0
	2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:85:ab:d0 brd ff:ff:ff:ff:ff:ff
    altname enp1s0
    inet 192.168.18.121/24 brd 192.168.18.255 scope global noprefixroute ens3
       valid_lft forever preferred_lft forever
    [root@ol926ain2 ~]# nmcli con modify 'enp3s0' ifname enp3s0 ipv4.method manual ipv4.addresses 192.168.100.102/24 ipv4.gateway 192.168.100.1 autoconnect yes ipv6.method disabled
    [root@ol926ain2 ~]# nmcli con down 'enp3s0'; nmcli con up 'enp3s0'
	[root@ol926ain2 ~]# ip addr show enp3s0 
	4: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:21:27:af brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.102/24 brd 192.168.100.255 scope global noprefixroute enp3s0
       valid_lft forever preferred_lft forever
	[root@ol926ain2 ~]# nmcli device
	DEVICE  TYPE      STATE                   CONNECTION 
	enp1s0  ethernet  connected               enp1s0       
	enp3s0  ethernet  connected               enp3s0     
	lo      loopback  connected (externally)  lo         
	[root@ol926ain2 ~]# nmcli connection show 
	NAME    UUID                                  TYPE      DEVICE 
	enp1s0  6b189709-3f1d-3683-bb3d-694e82554e82  ethernet  enp1s0 
	enp3s0  0c094cdd-0d7a-3cbb-a2a2-09e0eaf839e9  ethernet  enp3s0 
	lo      2928747e-520a-4089-9fd3-9f6a56a91144  loopback  lo   

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( DISABLE AVAHI )

    [root@ol926ain1 ~]# systemctl disable avahi-daemon.socket avahi-daemon.service 
    Removed "/etc/systemd/system/multi-user.target.wants/avahi-daemon.service".
    Removed "/etc/systemd/system/sockets.target.wants/avahi-daemon.socket".
    Removed "/etc/systemd/system/dbus-org.freedesktop.Avahi.service".
    [root@ol926ain1 ~]# systemctl mask avahi-daemon.socket avahi-daemon.service 
    Created symlink /etc/systemd/system/avahi-daemon.socket → /dev/null.
    Created symlink /etc/systemd/system/avahi-daemon.service → /dev/null.
    [root@ol926ain1 ~]# systemctl stop avahi-daemon.socket avahi-daemon.service

    [root@ol926ain2 ~]# systemctl disable avahi-daemon.socket avahi-daemon.service
    Removed "/etc/systemd/system/multi-user.target.wants/avahi-daemon.service".
    Removed "/etc/systemd/system/dbus-org.freedesktop.Avahi.service".
    Removed "/etc/systemd/system/sockets.target.wants/avahi-daemon.socket".
    [root@ol926ain2 ~]# systemctl mask avahi-daemon.socket avahi-daemon.service 
    Created symlink /etc/systemd/system/avahi-daemon.socket → /dev/null.
    Created symlink /etc/systemd/system/avahi-daemon.service → /dev/null.
    [root@ol926ain2 ~]# systemctl stop avahi-daemon.socket avahi-daemon.service

### PRE REQUIREMENTS ORACLE ENVIRONMENT ( SELINUX )

    [root@ol926ain1 ~]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    [root@ol926ain2 ~]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( PACKAGES )

    [root@ol926ain1 ~]# yum install -y oracle-ai-database-preinstall-26ai.x86_64
    [root@ol926ain2 ~]# yum install -y oracle-ai-database-preinstall-26ai.x86_64
    [root@ol926ain1 ~]# yum install -y https://yum.oracle.com/repo/OracleLinux/OL9/addons/x86_64/getPackage/oracleasm-support-3.1.1-4.el9.x86_64.rpm
    [root@ol926ain2 ~]# yum install -y https://yum.oracle.com/repo/OracleLinux/OL9/addons/x86_64/getPackage/oracleasm-support-3.1.1-4.el9.x86_64.rpm
    [root@ol926ain1 ~]# rpm -ivh oracleasmlib-3.1.1-1.el9.x86_64.rpm 
    [root@ol926ain2 ~]# rpm -ivh oracleasmlib-3.1.1-1.el9.x86_64.rpm 
    [root@ol926ain1 ~]# yum install -y chkconfig
    [root@ol926ain2 ~]# yum install -y chkconfig
    [root@ol926ain1 ~]# yum install -y iscsi-initiator-utils udisks2-iscsi 
    [root@ol926ain2 ~]# yum install -y iscsi-initiator-utils udisks2-iscsi 

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( PLUGGABLE AUTHENTICATION MODULES )

    [root@ol926ain1 ~]# echo "session         required        pam_limits.so" >> /etc/pam.d/su 
    [root@ol926ain1 ~]# echo "session         required        pam_unix.so" >> /etc/pam.d/su
    [root@ol926ain2 ~]# echo "session         required        pam_limits.so" >> /etc/pam.d/su 
    [root@ol926ain2 ~]# echo "session         required        pam_unix.so" >> /etc/pam.d/su 
    [root@ol926ain1 ~]# echo "session    required     pam_limits.so" >> /etc/pam.d/sshd
    [root@ol926ain1 ~]# echo "session    required     pam_unix.so" >> /etc/pam.d/sshd
    [root@ol926ain2 ~]# echo "session    required     pam_limits.so" >> /etc/pam.d/sshd
    [root@ol926ain2 ~]# echo "session    required     pam_unix.so" >> /etc/pam.d/sshd
    [root@ol926ain1 ~]# echo "session    required     pam_limits.so" >> /etc/pam.d/login
    [root@ol926ain1 ~]# echo "session    required     pam_unix.so" >> /etc/pam.d/login
    [root@ol926ain2 ~]# echo "session    required     pam_limits.so" >> /etc/pam.d/login
    [root@ol926ain2 ~]# echo "session    required     pam_unix.so" >> /etc/pam.d/login

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( SECURITY LIMITS )

    [root@ol926ain1 ~]# cat <<EOF >> /etc/security/limits.conf
	# oracle-ai-database-preinstall-26ai setting for nofile soft limit is 1024
	oracle		soft	nofile		1024
	grid		soft	nofile    	1024
	# oracle-ai-database-preinstall-26ai setting for nofile hard limit is 65536
	oracle		hard	nofile		65536
	grid		hard	nofile    	65536
	# oracle-ai-database-preinstall-26ai setting for nproc soft limit is 16384
	# refer orabug15971421 for more info.
	oracle		soft	nproc		16384
	grid		soft	nproc		16384
	# oracle-ai-database-preinstall-26ai setting for nproc hard limit is 16384
	oracle		hard	nproc		16384
	grid		hard	nproc		16384 
	# oracle-ai-database-preinstall-26ai setting for stack soft limit is 10240KB
	oracle		soft	stack		10240
	grid		soft	stack		10240
	# oracle-ai-database-preinstall-26ai setting for stack hard limit is 32768KB
	oracle		hard	stack		32768
	grid		hard	stack		32768
	# oracle-ai-database-preinstall-26ai setting for memlock hard limit is maximum of 128GB on x86_64 or 3GB on x86 OR 90 % of RAM
	oracle		hard	memlock		134217728
	grid		hard	memlock		134217728
	# oracle-ai-database-preinstall-26ai setting for memlock soft limit is maximum of 128GB on x86_64 or 3GB on x86 OR 90% of RAM
	oracle		soft	memlock		134217728
	grid		soft    memlock         134217728
	# oracle-ai-database-preinstall-26ai setting for data soft limit is 'unlimited'
	oracle		soft	data		unlimited
	grid		soft    data            unlimited
	# oracle-ai-database-preinstall-26ai setting for data hard limit is 'unlimited'
	oracle		hard	data		unlimited
	grid		hard	data		unlimited
	# End of file
    EOF
    [root@ol926ain2 ~]# cat <<EOF >> /etc/security/limits.conf
	# oracle-ai-database-preinstall-26ai setting for nofile soft limit is 1024
	oracle		soft	nofile		1024
	grid		soft	nofile    	1024
	# oracle-ai-database-preinstall-26ai setting for nofile hard limit is 65536
	oracle		hard	nofile		65536
	grid		hard	nofile    	65536
	# oracle-ai-database-preinstall-26ai setting for nproc soft limit is 16384
	# refer orabug15971421 for more info.
	oracle		soft	nproc		16384
	grid		soft	nproc		16384
	# oracle-ai-database-preinstall-26ai setting for nproc hard limit is 16384
	oracle		hard	nproc		16384
	grid		hard	nproc		16384 
	# oracle-ai-database-preinstall-26ai setting for stack soft limit is 10240KB
	oracle		soft	stack		10240
	grid		soft	stack		10240
	# oracle-ai-database-preinstall-26ai setting for stack hard limit is 32768KB
	oracle		hard	stack		32768
	grid		hard	stack		32768
	# oracle-ai-database-preinstall-26ai setting for memlock hard limit is maximum of 128GB on x86_64 or 3GB on x86 OR 90 % of RAM
	oracle		hard	memlock		134217728
	grid		hard	memlock		134217728
	# oracle-ai-database-preinstall-26ai setting for memlock soft limit is maximum of 128GB on x86_64 or 3GB on x86 OR 90% of RAM
	oracle		soft	memlock		134217728
	grid		soft    memlock         134217728
	# oracle-ai-database-preinstall-26ai setting for data soft limit is 'unlimited'
	oracle		soft	data		unlimited
	grid		soft    data            unlimited
	# oracle-ai-database-preinstall-26ai setting for data hard limit is 'unlimited'
	oracle		hard	data		unlimited
	grid		hard	data		unlimited
	# End of file
    EOF

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CREATE USERS )

    [root@ol926ain1 ~]# userdel oracle; rm -Rvf /home/oracle; rm -Rvf /var/mail/oracle 
    [root@ol926ain2 ~]# userdel oracle; rm -Rvf /home/oracle; rm -Rvf /var/mail/oracle 
    [root@ol926ain1 ~]# groupadd -g 54321 oinstall; groupadd -g 54322 dba; groupadd -g 54323 oper; groupadd -g 54324 backupdba; groupadd -g 54325 dgdba; groupadd -g 54326 kmdba; groupadd -g 54327 asmdba; groupadd -g 54328 asmoper; groupadd -g 54329 asmadmin; groupadd -g 54330 racdba; useradd -m -u 54331 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,asmdba,asmadmin,racdba -d /home/oracle -s /bin/bash  oracle; useradd -m -u 54332 -g oinstall -G dba,asmadmin,asmdba,asmoper -d /home/grid -s /bin/bash  grid; id oracle; id grid
    [root@ol926ain2 ~]# groupadd -g 54321 oinstall; groupadd -g 54322 dba; groupadd -g 54323 oper; groupadd -g 54324 backupdba; groupadd -g 54325 dgdba; groupadd -g 54326 kmdba; groupadd -g 54327 asmdba; groupadd -g 54328 asmoper; groupadd -g 54329 asmadmin; groupadd -g 54330 racdba; useradd -m -u 54331 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,asmdba,asmadmin,racdba -d /home/oracle -s /bin/bash  oracle; useradd -m -u 54332 -g oinstall -G dba,asmadmin,asmdba,asmoper -d /home/grid -s /bin/bash  grid; id oracle; id grid
    [root@ol926ain1 ~]# passwd oracle
    [root@ol926ain2 ~]# passwd oracle
    [root@ol926ain1 ~]# passwd grid
    [root@ol926ain2 ~]# passwd grid

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CREATE DIRECTORIES )

    [root@ol926ain1 ~]# mkdir -p /u01/app/grid; mkdir -p /u01/app/23.26.1/grid; mkdir -p /u01/app/oracle; mkdir -p /u01/app/oracle/product/23.26.1/dbhome_1; chmod -R 775 /u01; chown -R grid:oinstall /u01; chown -R oracle:oinstall /u01/app/oracle; chown oracle:oinstall -R /home/oracle
    [root@ol926ain2 ~]# mkdir -p /u01/app/grid; mkdir -p /u01/app/23.26.1/grid; mkdir -p /u01/app/oracle; mkdir -p /u01/app/oracle/product/23.26.1/dbhome_1; chmod -R 775 /u01; chown -R grid:oinstall /u01; chown -R oracle:oinstall /u01/app/oracle; chown oracle:oinstall -R /home/oracle

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE /ETC/RESOLV.CONF )

    [root@ol926ain1 ~]# cat <<EOF > /etc/resolv.conf
    nameserver 192.168.18.43
    search appsdba.info
    EOF
    [root@ol926ain1 ~]# chattr +i /etc/resolv.conf
    [root@ol926ain2 ~]# cat <<EOF > /etc/resolv.conf
    nameserver 192.168.18.43
    search appsdba.info
    EOF
    [root@ol926ain2 ~]# chattr +i /etc/resolv.conf

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( ENVIRONMENT VARIABLES NODE 1 )

    [root@ol926ain1 ~]# cat <<EOF > /home/grid/.bash_profile 
    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
            . ~/.bashrc
    fi

    # User specific environment and startup program

    PATH=$PATH:$HOME/.local/bin:$HOME/bin
    export ORACLE_SID=+ASM1
    export ORACLE_BASE=/u01/app/grid
    export ORACLE_HOME=/u01/app/23.26.1/grid
    export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH
    umask 22
    export PATH
    EOF
    [root@ol926ain1 ~]# chown grid:oinstall /home/grid/.bash_profile
    [root@ol926ain1 ~]# cat <<EOF > /home/oracle/.bash_profile
    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi

    # User specific environment and startup programs

    PATH=$PATH:$HOME/.local/bin:$HOME/bin
    export ORACLE_SID=oradbc1
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=\$ORACLE_BASE/product/23.26.1/dbhome_1
    export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH
    umask 22
    export PATH
    EOF
    [root@ol926ain1 ~]# chown oracle:oinstall /home/oracle/.bash_profile
    [root@ol926ain1 ~]# cat <<EOF > /root/.bash_profile 
    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi

    # User specific environment and startup programs

    PATH=$PATH:$HOME/bin
    export ORACLE_HOME=/u01/app/23.26.1/grid
    export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH
    export PATH
    EOF
    
###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( ENVIRONMENT VARIABLES NODE 2 )

    [root@ol926ain2 ~]# cat <<EOF > /home/grid/.bash_profile 
    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
            . ~/.bashrc
    fi

    # User specific environment and startup program

    PATH=$PATH:$HOME/.local/bin:$HOME/bin
    export ORACLE_SID=+ASM2
    export ORACLE_BASE=/u01/app/grid
    export ORACLE_HOME=/u01/app/23.26.1/grid
    export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH
    umask 22
    export PATH
    EOF
    [root@ol926ain2 ~]# chown grid:oinstall /home/grid/.bash_profile
    [root@ol926ain2 ~]# cat <<EOF > /home/oracle/.bash_profile
    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi

    # User specific environment and startup programs

    PATH=$PATH:$HOME/.local/bin:$HOME/bin
    export ORACLE_SID=oradbc2
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=\$ORACLE_BASE/product/23.26.1/dbhome_1
    export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH
    umask 22
    export PATH
    EOF
    [root@ol926ain2 ~]# chown oracle:oinstall /home/oracle/.bash_profile
    [root@ol926ain2 ~]# cat <<EOF > /root/.bash_profile 
    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi

    # User specific environment and startup programs

    PATH=$PATH:$HOME/bin
    export ORACLE_HOME=/u01/app/23.26.1/grid
    export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH
    export PATH
    EOF

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE ORACLE ASM LIBRARY NODE 1 )
    
    [root@ol926ain1 ~]# source /root/.bash_profile
    [root@ol926ain1 ~]# oracleasm configure -i
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

    [root@ol926ain2 ~]# source /root/.bash_profile
    [root@ol926ain2 ~]# oracleasm configure -i
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

    [root@ol926ain1 ~]# iscsiadm -m discovery -t sendtargets -p 192.168.18.46
	192.168.18.46:3260,1 iqn.2003-01.org.linux-iscsi.ol9scsi.x8664:sn.b4c74d69d968
	[root@ol926ain2 ~]# iscsiadm -m discovery -t sendtargets -p 192.168.18.46
	192.168.18.46:3260,1 iqn.2003-01.org.linux-iscsi.ol9scsi.x8664:sn.b4c74d69d968
	[root@ol926ain1 ~]# cat /etc/iscsi/initiatorname.iscsi
	InitiatorName=iqn.1994-05.com.redhat:a0bb1ac81cd4
	[root@ol926ain2 ~]# cat /etc/iscsi/initiatorname.iscsi
	InitiatorName=iqn.1994-05.com.redhat:a0822cd78296
    
###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( LOGIN ISCSI )
    
	[root@ol926ain1 ~]# iscsiadm -m node -T iqn.2003-01.org.linux-iscsi.ol9scsi.x8664:sn.b4c74d69d968 -p 192.168.18.46 -l
	[root@ol926ain2 ~]# iscsiadm -m node -T iqn.2003-01.org.linux-iscsi.ol9scsi.x8664:sn.b4c74d69d968 -p 192.168.18.46 -l
    
###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( AUTOMATIC LOGIN ISCSI )

	[root@ol926ain1 ~]# iscsiadm -m node -T iqn.2003-01.org.linux-iscsi.ol9scsi.x8664:sn.b4c74d69d968 -p 192.168.18.46 -o update -n node.startup -v automatic
	[root@ol926ain2 ~]# iscsiadm -m node -T iqn.2003-01.org.linux-iscsi.ol9scsi.x8664:sn.b4c74d69d968 -p 192.168.18.46 -o update -n node.startup -v automatic

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CHECK ISCSI DISKS )

	[root@ol926ain1 ~]# fdisk -l | grep "Disk /dev/sd"
	Disk /dev/sda: 59 GiB, 63350767616 bytes, 123731968 sectors
	Disk /dev/sdb: 30 GiB, 32212254720 bytes, 62914560 sectors
	Disk /dev/sdc: 30 GiB, 32212254720 bytes, 62914560 sectors
	Disk /dev/sdd: 30 GiB, 32212254720 bytes, 62914560 sectors
	Disk /dev/sde: 30 GiB, 32212254720 bytes, 62914560 sectors
	Disk /dev/sdf: 30 GiB, 32212254720 bytes, 62914560 sectors
	[root@ol926ain2 ~]# fdisk -l | grep "Disk /dev/sd"
	Disk /dev/sda: 59 GiB, 63350767616 bytes, 123731968 sectors
	Disk /dev/sdb: 30 GiB, 32212254720 bytes, 62914560 sectors
	Disk /dev/sdc: 30 GiB, 32212254720 bytes, 62914560 sectors
	Disk /dev/sdd: 30 GiB, 32212254720 bytes, 62914560 sectors
	Disk /dev/sde: 30 GiB, 32212254720 bytes, 62914560 sectors
	Disk /dev/sdf: 30 GiB, 32212254720 bytes, 62914560 sectors

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CREATE PARTITION ISCSI DISKS )

    [root@ol926ain1 ~]# fdisk /dev/sdb
    n > p > 1 > w
    [root@ol926ain1 ~]# fdisk /dev/sdc
    n > p > 1 > w
    [root@ol926ain1 ~]# fdisk /dev/sdd
    n > p > 1 > w
    [root@ol926ain1 ~]# fdisk /dev/sde
    n > p > 1 > w
    [root@ol926ain1 ~]# fdisk /dev/sdf
    n > p > 1 > w

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( GET ISCSI DISKS UUID )

	[root@ol926ain1 ~]# /usr/lib/udev/scsi_id -g -u -d /dev/sdb1 
	3600140530b1b516a4b546498ef061992
	[root@ol926ain1 ~]# /usr/lib/udev/scsi_id -g -u -d /dev/sdc1
	36001405f9da5bf8739e46bd9b78d941b
	[root@ol926ain1 ~]# /usr/lib/udev/scsi_id -g -u -d /dev/sdd1 
	36001405e56bcf503218482196cbd1ec3
	[root@ol926ain1 ~]# /usr/lib/udev/scsi_id -g -u -d /dev/sde1 
	36001405a758b88d83ec49fc81d5f21b3
	[root@ol926ain1 ~]# /usr/lib/udev/scsi_id -g -u -d /dev/sdf1
	360014054b4639dcf64b494abb68561b9

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CREATE ASM DEVICES RULES )

    [root@ol926ain1 ~]# cat <<EOF > /etc/udev/rules.d/99-oracle-asmdevices.rules
	KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="3600140530b1b516a4b546498ef061992", SYMLINK+="asm-disk1", OWNER="grid", GROUP="asmdba", MODE="0660"
	KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="36001405f9da5bf8739e46bd9b78d941b", SYMLINK+="asm-disk2", OWNER="grid", GROUP="asmdba", MODE="0660"
	KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="36001405e56bcf503218482196cbd1ec3", SYMLINK+="asm-disk3", OWNER="grid", GROUP="asmdba", MODE="0660"
	KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="36001405a758b88d83ec49fc81d5f21b3", SYMLINK+="asm-disk4", OWNER="grid", GROUP="asmdba", MODE="0660"
	KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="360014054b4639dcf64b494abb68561b9", SYMLINK+="asm-disk5", OWNER="grid", GROUP="asmdba", MODE="0660"
    EOF
    [root@ol926ain2 ~]# cat <<EOF > /etc/udev/rules.d/99-oracle-asmdevices.rules
	KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="3600140530b1b516a4b546498ef061992", SYMLINK+="asm-disk1", OWNER="grid", GROUP="asmdba", MODE="0660"
	KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="36001405f9da5bf8739e46bd9b78d941b", SYMLINK+="asm-disk2", OWNER="grid", GROUP="asmdba", MODE="0660"
	KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="36001405e56bcf503218482196cbd1ec3", SYMLINK+="asm-disk3", OWNER="grid", GROUP="asmdba", MODE="0660"
	KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="36001405a758b88d83ec49fc81d5f21b3", SYMLINK+="asm-disk4", OWNER="grid", GROUP="asmdba", MODE="0660"
	KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/\$parent", RESULT=="360014054b4639dcf64b494abb68561b9", SYMLINK+="asm-disk5", OWNER="grid", GROUP="asmdba", MODE="0660"
    EOF

    [root@ol926ain1 ~]# udevadm test /block/sdb/sdb1
    [root@ol926ain1 ~]# udevadm test /block/sdc/sdc1
    [root@ol926ain1 ~]# udevadm test /block/sdd/sdd1
    [root@ol926ain1 ~]# udevadm test /block/sde/sde1
    [root@ol926ain1 ~]# udevadm test /block/sdf/sdf1
    [root@ol926ain1 ~]# udevadm control --reload-rules
    [root@ol926ain1 ~]# /sbin/udevadm trigger
    [root@ol926ain2 ~]# udevadm test /block/sdb/sdb1
    [root@ol926ain2 ~]# udevadm test /block/sdc/sdc1
    [root@ol926ain2 ~]# udevadm test /block/sdd/sdd1
    [root@ol926ain2 ~]# udevadm test /block/sde/sde1
    [root@ol926ain2 ~]# udevadm test /block/sdf/sdf1
    [root@ol926ain2 ~]# udevadm control --reload-rules
    [root@ol926ain2 ~]# /sbin/udevadm trigger

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CHECK ASM DEVICES RULES )

	[root@ol926ain1 ~]# ls -ltr /dev/asm-disk*
	lrwxrwxrwx 1 root root 4 Jan 31 15:52 /dev/asm-disk5 -> sdf1
	lrwxrwxrwx 1 root root 4 Jan 31 15:52 /dev/asm-disk3 -> sdd1
	lrwxrwxrwx 1 root root 4 Jan 31 15:52 /dev/asm-disk1 -> sdb1
	lrwxrwxrwx 1 root root 4 Jan 31 15:52 /dev/asm-disk4 -> sde1
	lrwxrwxrwx 1 root root 4 Jan 31 15:52 /dev/asm-disk2 -> sdc1
	[root@ol926ain2 ~]# ls -ltr /dev/asm-disk*
	lrwxrwxrwx 1 root root 4 Jan 31 15:52 /dev/asm-disk5 -> sdf1
	lrwxrwxrwx 1 root root 4 Jan 31 15:52 /dev/asm-disk3 -> sdd1
	lrwxrwxrwx 1 root root 4 Jan 31 15:52 /dev/asm-disk1 -> sdb1
	lrwxrwxrwx 1 root root 4 Jan 31 15:52 /dev/asm-disk4 -> sde1
	lrwxrwxrwx 1 root root 4 Jan 31 15:52 /dev/asm-disk2 -> sdc1

###### SSH KEY EXCHANGE ( NODE 1 )

    [root@ol926ain1 ~]# su - root -c "ssh-keygen -t rsa"
    [root@ol926ain1 ~]# su - oracle -c "ssh-keygen -t rsa"
    [root@ol926ain1 ~]# su - grid -c "ssh-keygen -t rsa"
    [root@ol926ain1 ~]# su - root -c "cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys"
    [root@ol926ain1 ~]# su - oracle -c "cat /home/oracle/.ssh/id_rsa.pub > /home/oracle/.ssh/authorized_keys"
    [root@ol926ain1 ~]# su - grid -c "cat /home/grid/.ssh/id_rsa.pub > /home/grid/.ssh/authorized_keys"
    [root@ol926ain1 ~]# chmod 600 /root/.ssh/authorized_keys
    [root@ol926ain1 ~]# chmod 600 /home/oracle/.ssh/authorized_keys
    [root@ol926ain1 ~]# chmod 600 /home/grid/.ssh/authorized_keys
    [root@ol926ain1 ~]# ssh-copy-id -i .ssh/id_rsa.pub root@192.168.18.122
    [root@ol926ain1 ~]# su - oracle
    [oracle@ol926ain1 ~]$ ssh-copy-id -i .ssh/id_rsa.pub oracle@192.168.18.122
    [oracle@ol926ain1 ~]$ exit
    [root@ol926ain1 ~]# su - grid
    [grid@ol926ain1 ~]$ ssh-copy-id -i .ssh/id_rsa.pub grid@192.168.18.122
    [grid@ol926ain1 ~]$ exit
    
###### SSH KEY EXCHANGE ( NODE 2 )

    [root@ol926ain2 ~]# su - root -c "ssh-keygen -t rsa"
    [root@ol926ain2 ~]# su - oracle -c "ssh-keygen -t rsa"
    [root@ol926ain2 ~]# su - grid -c "ssh-keygen -t rsa"
    [root@ol926ain2 ~]# su - root -c "cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys"
    [root@ol926ain2 ~]# su - oracle -c "cat /home/oracle/.ssh/id_rsa.pub > /home/oracle/.ssh/authorized_keys"
    [root@ol926ain2 ~]# su - grid -c "cat /home/grid/.ssh/id_rsa.pub > /home/grid/.ssh/authorized_keys"
    [root@ol926ain2 ~]# chmod 600 /root/.ssh/authorized_keys
    [root@ol926ain2 ~]# chmod 600 /home/oracle/.ssh/authorized_keys
    [root@ol926ain2 ~]# chmod 600 /home/grid/.ssh/authorized_keys
    [root@ol926ain2 ~]# ssh-copy-id -i .ssh/id_rsa.pub root@192.168.18.121
    [root@ol926ain2 ~]# su - oracle
    [oracle@ol926ain2 ~]$ ssh-copy-id -i .ssh/id_rsa.pub oracle@192.168.18.121
    [oracle@ol926ain2 ~]$ exit
    [root@ol926ain2 ~]# su - grid
    [grid@ol926ain2 ~]$ ssh-copy-id -i .ssh/id_rsa.pub grid@192.168.18.121
    [grid@ol926ain2 ~]$ exit
    
###### COPY GRID INFRASTRUCTURE SOFTWARE

    [root@exated Downloads]# scp V1054596-01.zip grid@192.168.18.121:/u01/app/23.26.1/grid

###### UNZIP GRID INFRASTRUCTURE SOFTWARE

    [root@ol926ain1 ~]# su - grid
    [grid@ol926ain1 grid]$ cd /u01/app/23.26.1/grid/
    [grid@ol926ain1 grid]$ unzip V1054596-01.zip
    [grid@ol926ain1 grid]$ rm -vf V1054596-01.zip

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( INSTALL CVU PACKAGE )

    [root@ol926ain1 ~]# rpm -ivh /u01/app/23.26.1/grid/cv/rpm/cvuqdisk-1.0.10-1.rpm 
    aviso: /u01/app/23.26.1/grid/cv/rpm/cvuqdisk-1.0.10-1.rpm: Cabeçalho V3 RSA/SHA256 Signature, ID da chave ad986da3: NOKEY
    Verifying...                          ################################# [100%]
    Preparando...                         ################################# [100%]
    Using default group oinstall to install package
    Updating / installing...
        1:cvuqdisk-1.0.10-1                ################################# [100%]
    [root@ol926ain1 ~]# scp /u01/app/23.26.1/grid/cv/rpm/cvuqdisk-1.0.10-1.rpm root@ol926ain2:/root/
    [root@ol926ain1 ~]# ssh root@ol926ain2
    [root@ol926ain2 ~]# rpm -ivh cvuqdisk-1.0.10-1.rpm 
    aviso: cvuqdisk-1.0.10-1.rpm: Cabeçalho V3 RSA/SHA256 Signature, ID da chave ad986da3: NOKEY
    Verifying...                          ################################# [100%]
    Preparando...                         ################################# [100%]
    Using default group oinstall to install package
    Updating / installing...
       1:cvuqdisk-1.0.10-1                ################################# [100%]
    [root@ol926ain2 ~]# exit

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( RUNCLUVFY )

    [root@ol926ain1 ~]# su - grid
	[grid@ol926ain1 ~]$ /u01/app/23.26.1/grid/runcluvfy.sh stage -pre crsinst -n ol926ain1,ol926ain2 -verbose -method root -skip orachk
	Enter "ROOT" password:

	Initializing ...

	Performing following verification checks ...

	  Physical Memory ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     7.7509GB (8127440.0KB)    8GB (8388608.0KB)         passed    
	    ol926ain1     7.7509GB (8127440.0KB)    8GB (8388608.0KB)         passed    
	  Physical Memory ...PASSED
	  Available Physical Memory ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     7.3003GB (7654960.0KB)    50MB (51200.0KB)          passed    
	    ol926ain1     7.0628GB (7405868.0KB)    50MB (51200.0KB)          passed    
	  Available Physical Memory ...PASSED
	  Swap Size ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     8GB (8388604.0KB)         7.7509GB (8127440.0KB)    passed    
	    ol926ain1     8GB (8388604.0KB)         7.7509GB (8127440.0KB)    passed    
	  Swap Size ...PASSED
	  Free Space: ol926ain2:/usr,ol926ain2:/var,ol926ain2:/etc,ol926ain2:/sbin,ol926ain2:/tmp ...
	    Path              Node Name     Mount point   Available     Required      Status      
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    /usr              ol926ain2     /             41.668GB      25MB          passed      
	    /var              ol926ain2     /             41.668GB      5MB           passed      
	    /etc              ol926ain2     /             41.668GB      25MB          passed      
	    /sbin             ol926ain2     /             41.668GB      10MB          passed      
	    /tmp              ol926ain2     /             41.668GB      1GB           passed      
	  Free Space: ol926ain2:/usr,ol926ain2:/var,ol926ain2:/etc,ol926ain2:/sbin,ol926ain2:/tmp ...PASSED
	  Free Space: ol926ain1:/usr,ol926ain1:/var,ol926ain1:/etc,ol926ain1:/sbin,ol926ain1:/tmp ...
	    Path              Node Name     Mount point   Available     Required      Status      
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    /usr              ol926ain1     /             38.8024GB     25MB          passed      
	    /var              ol926ain1     /             38.8024GB     5MB           passed      
	    /etc              ol926ain1     /             38.8024GB     25MB          passed      
	    /sbin             ol926ain1     /             38.8024GB     10MB          passed      
	    /tmp              ol926ain1     /             38.8024GB     1GB           passed      
	  Free Space: ol926ain1:/usr,ol926ain1:/var,ol926ain1:/etc,ol926ain1:/sbin,ol926ain1:/tmp ...PASSED
	  User Existence: grid ...
	    Node Name     Status                    Comment                 
	    ------------  ------------------------  ------------------------
	    ol926ain2     passed                    exists(54332)           
	    ol926ain1     passed                    exists(54332)           

	    Users With Same UID: 54332 ...PASSED
	  User Existence: grid ...PASSED
	  Group Existence: asmadmin ...
	    Node Name     Status                    Comment                 
	    ------------  ------------------------  ------------------------
	    ol926ain2     passed                    exists                  
	    ol926ain1     passed                    exists                  
	  Group Existence: asmadmin ...PASSED
	  Group Existence: asmdba ...
	    Node Name     Status                    Comment                 
	    ------------  ------------------------  ------------------------
	    ol926ain2     passed                    exists                  
	    ol926ain1     passed                    exists                  
	  Group Existence: asmdba ...PASSED
	  Group Existence: oinstall ...
	    Node Name     Status                    Comment                 
	    ------------  ------------------------  ------------------------
	    ol926ain2     passed                    exists                  
	    ol926ain1     passed                    exists                  
	  Group Existence: oinstall ...PASSED
	  Group Membership: asmdba ...
	    Node Name         User Exists   Group Exists  User in Group  Status          
	    ----------------  ------------  ------------  ------------  ----------------
	    ol926ain2         yes           yes           yes           passed          
	    ol926ain1         yes           yes           yes           passed          
	  Group Membership: asmdba ...PASSED
	  Group Membership: asmadmin ...
	    Node Name         User Exists   Group Exists  User in Group  Status          
	    ----------------  ------------  ------------  ------------  ----------------
	    ol926ain2         yes           yes           yes           passed          
	    ol926ain1         yes           yes           yes           passed          
	  Group Membership: asmadmin ...PASSED
	  Group Membership: oinstall(Primary) ...
	    Node Name         User Exists   Group Exists  User in Group  Primary       Status      
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain2         yes           yes           yes           yes           passed      
	    ol926ain1         yes           yes           yes           yes           passed      
	  Group Membership: oinstall(Primary) ...PASSED
	  Run Level ...
	    Node Name     run level                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     5                         3,5                       passed    
	    ol926ain1     5                         3,5                       passed    
	  Run Level ...PASSED
	  Hard Limit: maximum open file descriptors ...
	    Node Name         Type          Available     Required      Status          
	    ----------------  ------------  ------------  ------------  ----------------
	    ol926ain2         hard          65536         65536         passed          
	    ol926ain1         hard          65536         65536         passed          
	  Hard Limit: maximum open file descriptors ...PASSED
	  Soft Limit: maximum open file descriptors ...
	    Node Name         Type          Available     Required      Status          
	    ----------------  ------------  ------------  ------------  ----------------
	    ol926ain2         soft          1024          1024          passed          
	    ol926ain1         soft          1024          1024          passed          
	  Soft Limit: maximum open file descriptors ...PASSED
	  Hard Limit: maximum user processes ...
	    Node Name         Type          Available     Required      Status          
	    ----------------  ------------  ------------  ------------  ----------------
	    ol926ain2         hard          16384         16384         passed          
	    ol926ain1         hard          16384         16384         passed          
	  Hard Limit: maximum user processes ...PASSED
	  Soft Limit: maximum user processes ...
	    Node Name         Type          Available     Required      Status          
	    ----------------  ------------  ------------  ------------  ----------------
	    ol926ain2         soft          16384         2047          passed          
	    ol926ain1         soft          16384         2047          passed          
	  Soft Limit: maximum user processes ...PASSED
	  Soft Limit: maximum stack size ...
	    Node Name         Type          Available     Required      Status          
	    ----------------  ------------  ------------  ------------  ----------------
	    ol926ain2         soft          10240         10240         passed          
	    ol926ain1         soft          10240         10240         passed          
	  Soft Limit: maximum stack size ...PASSED
	  Architecture ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     x86_64                    x86_64                    passed    
	    ol926ain1     x86_64                    x86_64                    passed    
	  Architecture ...PASSED
	  OS Kernel Version ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     6.12.0-105.51.5.el9uek.x86_64  5.15.0                    passed    
	    ol926ain1     6.12.0-105.51.5.el9uek.x86_64  5.15.0                    passed    
	  OS Kernel Version ...PASSED
	  OS Kernel Parameter: semmsl ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         250           250           250           passed      
	    ol926ain2         250           250           250           passed      
	  OS Kernel Parameter: semmsl ...PASSED
	  OS Kernel Parameter: semmns ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         32000         32000         32000         passed      
	    ol926ain2         32000         32000         32000         passed      
	  OS Kernel Parameter: semmns ...PASSED
	  OS Kernel Parameter: semopm ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         100           100           100           passed      
	    ol926ain2         100           100           100           passed      
	  OS Kernel Parameter: semopm ...PASSED
	  OS Kernel Parameter: semmni ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         128           128           128           passed      
	    ol926ain2         128           128           128           passed      
	  OS Kernel Parameter: semmni ...PASSED
	  OS Kernel Parameter: shmmax ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         4398046511104  4398046511104  4161249280    passed      
	    ol926ain2         4398046511104  4398046511104  4161249280    passed      
	  OS Kernel Parameter: shmmax ...PASSED
	  OS Kernel Parameter: shmmni ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         4096          4096          4096          passed      
	    ol926ain2         4096          4096          4096          passed      
	  OS Kernel Parameter: shmmni ...PASSED
	  OS Kernel Parameter: shmall ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         1073741824    1073741824    1073741824    passed      
	    ol926ain2         1073741824    1073741824    1073741824    passed      
	  OS Kernel Parameter: shmall ...PASSED
	  OS Kernel Parameter: file-max ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         6815744       6815744       6815744       passed      
	    ol926ain2         6815744       6815744       6815744       passed      
	  OS Kernel Parameter: file-max ...PASSED
	  OS Kernel Parameter: ip_local_port_range ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         between 9000 & 65535  between 9000 & 65535  between 9000 & 65535  passed      
	    ol926ain2         between 9000 & 65535  between 9000 & 65535  between 9000 & 65535  passed      
	  OS Kernel Parameter: ip_local_port_range ...PASSED
	  OS Kernel Parameter: rmem_default ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         262144        262144        262144        passed      
	    ol926ain2         262144        262144        262144        passed      
	  OS Kernel Parameter: rmem_default ...PASSED
	  OS Kernel Parameter: rmem_max ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         4194304       4194304       4194304       passed      
	    ol926ain2         4194304       4194304       4194304       passed      
	  OS Kernel Parameter: rmem_max ...PASSED
	  OS Kernel Parameter: wmem_default ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         262144        262144        262144        passed      
	    ol926ain2         262144        262144        262144        passed      
	  OS Kernel Parameter: wmem_default ...PASSED
	  OS Kernel Parameter: wmem_max ...
    	Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         1048576       1048576       1048576       passed      
	    ol926ain2         1048576       1048576       1048576       passed      
	  OS Kernel Parameter: wmem_max ...PASSED
	  OS Kernel Parameter: aio-max-nr ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         1048576       1048576       1048576       passed      
	    ol926ain2         1048576       1048576       1048576       passed      
	  OS Kernel Parameter: aio-max-nr ...PASSED
	  OS Kernel Parameter: panic_on_oops ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         1             1             1             passed      
	    ol926ain2         1             1             1             passed      
	  OS Kernel Parameter: panic_on_oops ...PASSED
	  OS Kernel Parameter: kernel.panic ...
	    Node Name         Current       Configured    Required      Status        Comment     
	    ----------------  ------------  ------------  ------------  ------------  ------------
	    ol926ain1         10            10            at least 1    passed      
	    ol926ain2         10            10            at least 1    passed      
	  OS Kernel Parameter: kernel.panic ...PASSED
	  Package: binutils-2.35.2 ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     binutils-2.35.2-67.0.1.el9  binutils-2.35.2           passed    
	    ol926ain1     binutils-2.35.2-67.0.1.el9  binutils-2.35.2           passed    
	  Package: binutils-2.35.2 ...PASSED
	  Package: compat-openssl11-1.1.1 (x86_64) ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     compat-openssl11(x86_64)-1.1.1k-5.el9_6.1  compat-openssl11(x86_64)-1.1.1  passed    
	    ol926ain1     compat-openssl11(x86_64)-1.1.1k-5.el9_6.1  compat-openssl11(x86_64)-1.1.1  passed    
	  Package: compat-openssl11-1.1.1 (x86_64) ...PASSED
	  Package: fontconfig-2.14.0 (x86_64) ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     fontconfig(x86_64)-2.14.0-2.el9_1  fontconfig(x86_64)-2.14.0  passed    
	    ol926ain1     fontconfig(x86_64)-2.14.0-2.el9_1  fontconfig(x86_64)-2.14.0  passed    
	  Package: fontconfig-2.14.0 (x86_64) ...PASSED
	  Package: libxcrypt-compat-4.4.18 ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     libxcrypt-compat-4.4.18-3.el9  libxcrypt-compat-4.4.18   passed    
	    ol926ain1     libxcrypt-compat-4.4.18-3.el9  libxcrypt-compat-4.4.18   passed    
	  Package: libxcrypt-compat-4.4.18 ...PASSED
	  Package: libgcc-11.3.1 (x86_64) ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     libgcc(x86_64)-11.5.0-11.0.1.el9  libgcc(x86_64)-11.3.1     passed    
	    ol926ain1     libgcc(x86_64)-11.5.0-11.0.1.el9  libgcc(x86_64)-11.3.1     passed    
	  Package: libgcc-11.3.1 (x86_64) ...PASSED
	  Package: libstdc++-11.3.1 (x86_64) ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     libstdc++(x86_64)-11.5.0-11.0.1.el9  libstdc++(x86_64)-11.3.1  passed    
	    ol926ain1     libstdc++(x86_64)-11.5.0-11.0.1.el9  libstdc++(x86_64)-11.3.1  passed    
	  Package: libstdc++-11.3.1 (x86_64) ...PASSED
	  Package: sysstat-12.5.4 ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     sysstat-12.5.4-9.0.2.el9  sysstat-12.5.4            passed    
	    ol926ain1     sysstat-12.5.4-9.0.2.el9  sysstat-12.5.4            passed    
	  Package: sysstat-12.5.4 ...PASSED
	  Package: make-4.3 ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     make-4.3-8.el9            make-4.3                  passed    
	    ol926ain1     make-4.3-8.el9            make-4.3                  passed    
	  Package: make-4.3 ...PASSED
	  Package: glibc-2.34 (x86_64) ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     glibc(x86_64)-2.34-231.0.1.el9  glibc(x86_64)-2.34        passed    
	    ol926ain1     glibc(x86_64)-2.34-231.0.1.el9  glibc(x86_64)-2.34        passed    
	  Package: glibc-2.34 (x86_64) ...PASSED
	  Package: glibc-devel-2.34 (x86_64) ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     glibc-devel(x86_64)-2.34-231.0.1.el9  glibc-devel(x86_64)-2.34  passed    
	    ol926ain1     glibc-devel(x86_64)-2.34-231.0.1.el9  glibc-devel(x86_64)-2.34  passed    
	  Package: glibc-devel-2.34 (x86_64) ...PASSED
	  Package: libaio-0.3.111 (x86_64) ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     libaio(x86_64)-0.3.111-13.el9  libaio(x86_64)-0.3.111    passed    
	    ol926ain1     libaio(x86_64)-0.3.111-13.el9  libaio(x86_64)-0.3.111    passed    
	  Package: libaio-0.3.111 (x86_64) ...PASSED
	  Package: nfs-utils-2.5.4 ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     nfs-utils-2.5.4-38.0.1.el9  nfs-utils-2.5.4           passed    
	    ol926ain1     nfs-utils-2.5.4-38.0.1.el9  nfs-utils-2.5.4           passed    
	  Package: nfs-utils-2.5.4 ...PASSED
	  Package: smartmontools-7.2-6 ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     smartmontools-7.2-9.el9   smartmontools-7.2-6       passed    
	    ol926ain1     smartmontools-7.2-9.el9   smartmontools-7.2-6       passed    
	  Package: smartmontools-7.2-6 ...PASSED
	  Package: net-tools-2.0-0.62 ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     net-tools-2.0-0.64.20160912git.el9  net-tools-2.0-0.62        passed    
	    ol926ain1     net-tools-2.0-0.64.20160912git.el9  net-tools-2.0-0.62        passed    
	  Package: net-tools-2.0-0.62 ...PASSED
	  Package: policycoreutils-3.5-1 ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     policycoreutils-3.6-3.el9  policycoreutils-3.5-1     passed    
	    ol926ain1     policycoreutils-3.6-3.el9  policycoreutils-3.5-1     passed    
	  Package: policycoreutils-3.5-1 ...PASSED
	  Package: policycoreutils-python-utils-3.5-1 ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     policycoreutils-python-utils-3.6-3.el9  policycoreutils-python-utils-3.5-1  passed    
	    ol926ain1     policycoreutils-python-utils-3.6-3.el9  policycoreutils-python-utils-3.5-1  passed    
	  Package: policycoreutils-python-utils-3.5-1 ...PASSED
	  Users With Same UID: 0 ...PASSED
	  Current Group ID ...PASSED
	  Root user consistency ...
	    Node Name                             Status                  
	    ------------------------------------  ------------------------
	    ol926ain2                             passed                  
	    ol926ain1                             passed                  
	  Root user consistency ...PASSED
	  Package: psmisc-22.6-19 ...
	    Node Name     Available                 Required                  Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     psmisc-23.4-3.el9         psmisc-22.6-19            passed    
	    ol926ain1     psmisc-23.4-3.el9         psmisc-22.6-19            passed    
	  Package: psmisc-22.6-19 ...PASSED
	  Host name ...PASSED
	  Node Connectivity ...
	    Hosts File ...
	    Node Name                             Status                  
	    ------------------------------------  ------------------------
	    ol926ain1                             passed                  
	    ol926ain2                             passed                  
	    Hosts File ...PASSED
	
	Interface information for node "ol926ain2"
	
		Name   IP Address      Subnet          Gateway         Def. Gateway    HW Address        MTU   
		------ --------------- --------------- --------------- --------------- ----------------- ------
		ens3   192.168.18.122  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:B7:46:01 1500  
		ens5   192.168.100.102 192.168.100.0   0.0.0.0         192.168.100.1   52:54:00:C2:F7:E6 1500  
	
	Interface information for node "ol926ain1"
	
		Name   IP Address      Subnet          Gateway         Def. Gateway    HW Address        MTU   
		------ --------------- --------------- --------------- --------------- ----------------- ------
		ens3   192.168.18.121  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:85:AB:D0 1500  
		ens5   192.168.100.101 192.168.100.0   0.0.0.0         192.168.100.1   52:54:00:EE:2F:B4 1500  
	
	Check: MTU consistency of the subnet "192.168.18.0".
	
		Node              Name          IP Address    Subnet        MTU             
		----------------  ------------  ------------  ------------  ----------------
		ol926ain2         ens3          192.168.18.122  192.168.18.0  1500            
		ol926ain1         ens3          192.168.18.121  192.168.18.0  1500            

	Check: MTU consistency of the subnet "192.168.100.0".

		Node              Name          IP Address    Subnet        MTU             
		----------------  ------------  ------------  ------------  ----------------
		ol926ain2         ens5          192.168.100.102  192.168.100.0  1500            
		ol926ain1         ens5          192.168.100.101  192.168.100.0  1500            

	 	Source                      Destination                 Connected?                
		--------------------------  --------------------------  --------------------------
		ol926ain1[ens3:192.168.18.121]  ol926ain2[ens3:192.168.18.122]  yes                       

     	Source                      Destination                 Connected?                
	 	--------------------------  --------------------------  --------------------------
		ol926ain1[ens5:192.168.100.101]  ol926ain2[ens5:192.168.100.102]  yes                       
		Check that maximum (MTU) size packet goes through subnet ...PASSED
		subnet mask consistency for subnet "192.168.18.0" ...PASSED
		subnet mask consistency for subnet "192.168.100.0" ...PASSED
		Node Connectivity ...PASSED
		Multicast or broadcast check ...
		Checking subnet "192.168.18.0" for multicast communication with multicast
		group "224.0.0.251"

		Subnet        Network Type              Multicast Enabled       	
		------------  ------------------------  ------------------------
		192.168.18.0  PRIVATE                   TRUE                    
		Multicast or broadcast check ...PASSED
		ASMLib installation and configuration verification. ...
		'/etc/init.d/oracleasm' ...PASSED
		'/dev/oracleasm' ...PASSED

    	Node Name                             Status                  
    	------------------------------------  ------------------------
    	ol926ain1                             passed                  
      	ol926ain2                             passed                  
	  	ASMLib installation and configuration verification. ...PASSED
	  	Network Time Protocol (NTP) ...
    	Daemon 'chronyd' ...
		Node Name                             Running?                
 		------------------------------------  ------------------------
	 	ol926ain2                             yes                     
  		ol926ain1                             yes                     

	    Daemon 'chronyd' ...PASSED
	    NTP daemon or service using UDP port 123 ...
		Node Name                             Port Open?              
		------------------------------------  ------------------------
  		ol926ain2                             yes                     
  		ol926ain1                             yes                     

	    NTP daemon or service using UDP port 123 ...PASSED
	    chrony daemon is synchronized with at least one external time source ...PASSED
	  Network Time Protocol (NTP) ...PASSED
	  Same core file name pattern ...PASSED
	  User Mask ...
	    Node Name     Available                 Required                  Comment   
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     0022                      0022                      passed    
	    ol926ain1     0022                      0022                      passed    
	  User Mask ...PASSED
	  User Not In Group "root": grid ...
	    Node Name     Status                    Comment                 
	    ------------  ------------------------  ------------------------
	    ol926ain2     passed                    does not exist          
	    ol926ain1     passed                    does not exist          
	  User Not In Group "root": grid ...PASSED
	  Time zone consistency ...PASSED
	  Path existence, ownership, permissions and attributes ...
	    Path "/var" ...PASSED
	    Path "/dev/shm" ...PASSED
	  Path existence, ownership, permissions and attributes ...PASSED
	  Time offset between nodes ...PASSED
	  resolv.conf Integrity ...
	    Node Name                             Status                  
	    ------------------------------------  ------------------------
	    ol926ain1                             passed                  
	    ol926ain2                             passed                  
	
	checking response for name "ol926ain2" from each of the name servers specified in "/etc/resolv.conf"

	    Node Name     Source                    Comment                   Status    
	    ------------  ------------------------  ------------------------  ----------
	    ol926ain2     192.168.18.43             IPv4                      passed    

	checking response for name "ol926ain1" from each of the name servers specified
	in "/etc/resolv.conf"
	
		Node Name     Source                    Comment                   Status    
		------------  ------------------------  ------------------------  ----------
		ol926ain1     192.168.18.43             IPv4                      passed    
	resolv.conf Integrity ...PASSED
  	DNS/NIS name service ...PASSED
  	Daemon "avahi-daemon" not configured and running ...
	    Node Name     Configured                Status                  
	    ------------  ------------------------  ------------------------
	    ol926ain2     no                        passed                  
	    ol926ain1     no                        passed                  

	    Node Name     Running?                  Status                  
	    ------------  ------------------------  ------------------------
	    ol926ain2     no                        passed                  
	    ol926ain1     no                        passed                  
	Daemon "avahi-daemon" not configured and running ...PASSED
	Daemon "proxyt" not configured and running ...
	    Node Name     Configured                Status                  
	    ------------  ------------------------  ------------------------
	    ol926ain2     no                        passed                  
	    ol926ain1     no                        passed                  

	    Node Name     Running?                  Status                  
	    ------------  ------------------------  ------------------------
	    ol926ain2     no                        passed                  
	    ol926ain1     no                        passed                  
  	Daemon "proxyt" not configured and running ...PASSED
  	Domain Sockets ...PASSED
  	User Equivalence ...PASSED
  	RPM Package Manager database ...PASSED
  	Maximum locked memory check ...PASSED
  	/dev/shm mounted as temporary file system ...PASSED
  	File system mount option hidepid for proc filesystem ...PASSED
  	SCP binary check ...PASSED
  	Systemd login manager IPC parameter ...PASSED
  	cgroup OS compatibility ...PASSED

	Pre-check for cluster services setup was successful. 

	CVU operation performed:      stage -pre crsinst
	Date:                         Feb 1, 2026, 11:54:41 AM
	CVU version:                  23.26.1.0.0 (010926x8664)
	CVU home:                     /u01/app/23.26.1/grid
	User:                         grid
	Operating system:             Linux6.12.0-105.51.5.el9uek.x86_64

###### CHANGE CV_ASSUME_DISTID PARAMETER 

    [root@ol926ain1 ~]# vi /u01/app/23.26.1/grid/cv/admin/cvu_config
	CV_ASSUME_DISTID=OL9

###### INSTALL GRID 26AI 

	[root@ol926ain1 ~]# xhost + 
	[root@ol926ain1 ~]# su - grid
	[grid@ol926ain1 ~]$ export DISPLAY=:0.0 
	[grid@ol926ain1 ~]$ /u01/app/23.26.1/grid/gridSetup.sh
	
![oracle database 26ai grid_001](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_001.png)

![oracle database 26ai grid_002](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_002.png)

![oracle database 26ai grid_003](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_003.png)

![oracle database 26ai grid_004](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_004.png)

![oracle database 26ai grid_005](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_005.png)

![oracle database 26ai grid_006](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_006.png)

![oracle database 26ai grid_007](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_007.png)

![oracle database 26ai grid_008](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_008.png)

![oracle database 26ai grid_009](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_009.png)

![oracle database 26ai grid_010](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_010.png)

![oracle database 26ai grid_011](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_011.png)

![oracle database 26ai grid_012](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_012.png)

![oracle database 26ai grid_013](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_013.png)

![oracle database 26ai grid_014](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_014.png)

![oracle database 26ai grid_015](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_015.png)

![oracle database 26ai grid_016](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_016.png)

![oracle database 26ai grid_017](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_017.png)

![oracle database 26ai grid_018](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/grid_018.png)

###### INSTALL GRID 26AI RUN CONFIGURATION SCRIPTS {orainstRoot.sh} NODE 1

	[root@ol926ain1 ~]# /u01/app/oraInventory/orainstRoot.sh
	Changing permissions of /u01/app/oraInventory.
	Adding read,write permissions for group.
	Removing read,write,execute permissions for world.

	Changing groupname of /u01/app/oraInventory to oinstall.
	The execution of the script is complete.

###### INSTALL GRID 26AI RUN CONFIGURATION SCRIPTS {orainstRoot.sh} NODE 2

	[root@ol926ain2 ~]# /u01/app/oraInventory/orainstRoot.sh
	Changing permissions of /u01/app/oraInventory.
	Adding read,write permissions for group.
	Removing read,write,execute permissions for world.

	Changing groupname of /u01/app/oraInventory to oinstall.
	The execution of the script is complete.

###### INSTALL GRID 26AI RUN CONFIGURATION SCRIPTS {root.sh} NODE 1

	[root@ol926ain1 ~]# /u01/app/23.26.1/grid/root.sh
	Performing root user operation.

	The following environment variables are set as:
    	ORACLE_OWNER= grid
    	ORACLE_HOME=  /u01/app/23.26.1/grid

	Enter the full pathname of the local bin directory: [/usr/local/bin]: 

	Entries will be added to the /etc/oratab file as needed by
	Database Configuration Assistant when a database is created
	Finished running generic part of root script.
	Now product-specific root actions will be performed.
	RAC option enabled on: Linux
	Executing command '/u01/app/23.26.1/grid/perl/bin/perl -I/u01/app/23.26.1/grid/perl/lib -I/u01/app/23.26.1/grid/crs/install /u01/app/23.26.1/grid/crs/install/rootcrs.pl '
	Using configuration parameter file: /u01/app/23.26.1/grid/crs/install/crsconfig_params
	The log of current session can be found at:
	  /u01/app/grid/crsdata/ol926ain1/crsconfig/rootcrs_ol926ain1_2026-02-05_08-14-46PM.log
	2026/02/05 20:14:49 CLSRSC-594: Executing installation step 1 of 18: 'ValidateEnv'.
	2026/02/05 20:14:49 CLSRSC-594: Executing installation step 2 of 18: 'CheckRootCert'.
	2026/02/05 20:14:49 CLSRSC-594: Executing installation step 3 of 18: 'GenSiteGUIDs'.
	2026/02/05 20:14:50 CLSRSC-594: Executing installation step 4 of 18: 'SetupOSD'.
	2026/02/05 20:14:50 CLSRSC-594: Executing installation step 5 of 18: 'CheckCRSConfig'.
	2026/02/05 20:14:50 CLSRSC-594: Executing installation step 6 of 18: 'SetupLocalGPNP'.
	2026/02/05 20:14:51 CLSRSC-594: Executing installation step 7 of 18: 'CreateRootCert'.
	2026/02/05 20:14:51 CLSRSC-594: Executing installation step 8 of 18: 'ConfigOLR'.
	2026/02/05 20:14:51 CLSRSC-594: Executing installation step 9 of 18: 'ConfigCHMOS'.
	2026/02/05 20:14:51 CLSRSC-594: Executing installation step 10 of 18: 'CreateOHASD'.
	2026/02/05 20:14:52 CLSRSC-594: Executing installation step 11 of 18: 'ConfigOHASD'.
	2026/02/05 20:14:56 CLSRSC-594: Executing installation step 12 of 18: 'SetupTFA'.
	2026/02/05 20:14:56 CLSRSC-594: Executing installation step 13 of 18: 'InstallACFS'.
	2026/02/05 20:14:58 CLSRSC-594: Executing installation step 14 of 18: 'CheckFirstNode'.
	2026/02/05 20:14:58 CLSRSC-594: Executing installation step 15 of 18: 'InitConfig'.
	CRS-4256: Updating the profile
	Successful addition of voting disk 39f7ba31af5f4fc7bf8488ab79092348.
	Successfully replaced voting disk group with +DATA.
	CRS-4256: Updating the profile
	CRS-4266: Voting file(s) successfully replaced
	##  STATE    File Universal Id                File Name Disk group
	--  -----    -----------------                --------- ---------
	 1. ONLINE   39f7ba31af5f4fc7bf8488ab79092348 (/dev/asm-disk1) [DATA]
	Located 1 voting disk(s).
	2026/02/05 20:15:50 CLSRSC-594: Executing installation step 16 of 18: 'StartCluster'.
	2026/02/05 20:16:10 CLSRSC-343: Successfully started Oracle Clusterware stack
	2026/02/05 20:16:11 CLSRSC-4002: Successfully installed Oracle Autonomous Health Framework (AHF).
	2026/02/05 20:16:12 CLSRSC-594: Executing installation step 17 of 18: 'ConfigNode'.
	clscfg: EXISTING configuration version 23 detected.
	Successfully accumulated necessary OCR keys.
	Creating OCR keys for user 'root', privgrp 'root'..
	Operation successful.
	2026/02/05 20:16:36 CLSRSC-594: Executing installation step 18 of 18: 'PostConfig'.
	2026/02/05 20:17:02 CLSRSC-325: Configure Oracle Grid Infrastructure for a Cluster ... succeeded

###### INSTALL GRID 26AI RUN CONFIGURATION SCRIPTS {root.sh} NODE 2

	[root@ol926ain2 ~]# /u01/app/23.26.1/grid/root.sh 
	Performing root user operation.
	
	The following environment variables are set as:
	    ORACLE_OWNER= grid
	    ORACLE_HOME=  /u01/app/23.26.1/grid
	
	Enter the full pathname of the local bin directory: [/usr/local/bin]: 
	
	Entries will be added to the /etc/oratab file as needed by
	Database Configuration Assistant when a database is created
	Finished running generic part of root script.
	Now product-specific root actions will be performed.
	RAC option enabled on: Linux
	Executing command '/u01/app/23.26.1/grid/perl/bin/perl -I/u01/app/23.26.1/grid/perl/lib -I/u01/app/23.26.1/grid/crs/install /u01/app/23.26.1/grid/crs/install/rootcrs.pl '
	Using configuration parameter file: /u01/app/23.26.1/grid/crs/install/crsconfig_params
	The log of current session can be found at:
	  /u01/app/grid/crsdata/ol926ain2/crsconfig/rootcrs_ol926ain2_2026-02-05_08-17-12PM.log
	2026/02/05 20:17:15 CLSRSC-594: Executing installation step 1 of 18: 'ValidateEnv'.
	2026/02/05 20:17:15 CLSRSC-594: Executing installation step 2 of 18: 'CheckRootCert'.
	2026/02/05 20:17:16 CLSRSC-594: Executing installation step 3 of 18: 'GenSiteGUIDs'.
	2026/02/05 20:17:16 CLSRSC-594: Executing installation step 4 of 18: 'SetupOSD'.
	2026/02/05 20:17:16 CLSRSC-594: Executing installation step 5 of 18: 'CheckCRSConfig'.
	2026/02/05 20:17:16 CLSRSC-594: Executing installation step 6 of 18: 'SetupLocalGPNP'.
	2026/02/05 20:17:16 CLSRSC-594: Executing installation step 7 of 18: 'CreateRootCert'.
	2026/02/05 20:17:16 CLSRSC-594: Executing installation step 8 of 18: 'ConfigOLR'.
	2026/02/05 20:17:17 CLSRSC-594: Executing installation step 9 of 18: 'ConfigCHMOS'.
	2026/02/05 20:17:17 CLSRSC-594: Executing installation step 10 of 18: 'CreateOHASD'.
	2026/02/05 20:17:17 CLSRSC-594: Executing installation step 11 of 18: 'ConfigOHASD'.
	2026/02/05 20:17:32 CLSRSC-330: Adding Clusterware entries to file 'oracle-ohasd.service'
	2026/02/05 20:17:39 CLSRSC-594: Executing installation step 12 of 18: 'SetupTFA'.
	2026/02/05 20:17:39 CLSRSC-594: Executing installation step 13 of 18: 'InstallACFS'.
	2026/02/05 20:17:40 CLSRSC-594: Executing installation step 14 of 18: 'CheckFirstNode'.
	2026/02/05 20:17:40 CLSRSC-594: Executing installation step 15 of 18: 'InitConfig'.
	2026/02/05 20:17:47 CLSRSC-594: Executing installation step 16 of 18: 'StartCluster'.
	2026/02/05 20:17:58 CLSRSC-343: Successfully started Oracle Clusterware stack
	2026/02/05 20:17:58 CLSRSC-594: Executing installation step 17 of 18: 'ConfigNode'.
	2026/02/05 20:17:58 CLSRSC-594: Executing installation step 18 of 18: 'PostConfig'.
	2026/02/05 20:18:00 CLSRSC-325: Configure Oracle Grid Infrastructure for a Cluster ... succeeded
	2026/02/05 20:19:00 CLSRSC-4002: Successfully installed Oracle Autonomous Health Framework (AHF).

###### POST INSTALL CHECK ENVIRONMENT ( RUNCLUVFY )

    [root@ol926ain1 ~]# su - grid
    [grid@ol926ain1 ~]$ /u01/app/23.7.0/grid/runcluvfy.sh stage -post crsinst -n ol926ain1,ol926ain2 -verbose -method root
    Digite a senha de "ROOT":

    Initializing ...

    Performing following verification checks ...

    Conectividade de Nó ...
    Arquivo dos Hosts ...
    Nome do Nó                            Status                  
    ------------------------------------  ------------------------
    ol926ain1                                 aprovado                
    ol926ain2                                 aprovado                
    Arquivo dos Hosts ...APROVADO

    Informações de interface para o nó "ol926ain1"

    Nome   Endereço IP     Sub-rede        Gateway         Gateway Def.    Endereço HW       MTU   
    ------ --------------- --------------- --------------- --------------- ----------------- ------
    enp1s0 192.168.18.121  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:28:86:AA 1500  
    enp1s0 192.168.18.185  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:28:86:AA 1500   
    enp1s0 192.168.18.184  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:28:86:AA 1500  
    enp1s0 192.168.18.187  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:28:86:AA 1500  
    enp3s0 192.168.100.101 192.168.100.0   0.0.0.0         192.168.100.1   52:54:00:7F:44:40 1500  

    Informações de interface para o nó "ol926ain2"

    Nome   Endereço IP     Sub-rede        Gateway         Gateway Def.    Endereço HW       MTU   
    ------ --------------- --------------- --------------- --------------- ----------------- ------
    enp1s0 192.168.18.122  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:6B:00:2D 1500  
    enp1s0 192.168.18.186  192.168.18.0    0.0.0.0         192.168.100.1   52:54:00:6B:00:2D 1500  
    enp3s0 192.168.100.102 192.168.100.0   0.0.0.0         192.168.100.1   52:54:00:5D:35:1F 1500  
    
    Verificar: Consistência de MTU das interfaces privadas da sub-rede "192.168.100.0"

    Nó                Nome          Endereço IP   Sub-rede      MTU             
    ----------------  ------------  ------------  ------------  ----------------
    ol926ain1             enp3s0        192.168.100.101  192.168.100.0  1500            
    ol926ain2             enp3s0        192.168.100.102  192.168.100.0  1500            

    Verificar: Consistência de MTU da sub-rede "192.168.18.0".

    Nó                Nome          Endereço IP   Sub-rede      MTU             
    ----------------  ------------  ------------  ------------  ----------------
    ol926ain1             enp1s0        192.168.18.121  192.168.18.0  1500            
    ol926ain1             enp1s0        192.168.18.185  192.168.18.0  1500                      
    ol926ain1             enp1s0        192.168.18.184  192.168.18.0  1500            
    ol926ain1             enp1s0        192.168.18.187  192.168.18.0  1500            
    ol926ain2             enp1s0        192.168.18.122  192.168.18.0  1500                     
    ol926ain2             enp1s0        192.168.18.186  192.168.18.0  1500            

    Origem                      Destino                     Conectado?                
    --------------------------  --------------------------  --------------------------
    ol926ain1[enp1s0:192.168.18.121]  ol926ain2[enp1s0:192.168.18.122]  sim                                            
    ol926ain1[enp1s0:192.168.18.121]  ol926ain2[enp1s0:192.168.18.186]  sim                       
    ol926ain1[enp1s0:192.168.18.185]  ol926ain2[enp1s0:192.168.18.122]  sim                                         
    ol926ain1[enp1s0:192.168.18.185]  ol926ain2[enp1s0:192.168.18.186]  sim                                           
    ol926ain1[enp1s0:192.168.18.184]  ol926ain2[enp1s0:192.168.18.122]  sim                                             
    ol926ain1[enp1s0:192.168.18.184]  ol926ain2[enp1s0:192.168.18.186]  sim                       
    ol926ain1[enp1s0:192.168.18.187]  ol926ain2[enp1s0:192.168.18.122]  sim                                           
    ol926ain1[enp1s0:192.168.18.187]  ol926ain2[enp1s0:192.168.18.186]  sim                       

    Origem                      Destino                     Conectado?                
    --------------------------  --------------------------  --------------------------
    ol926ain1[enp3s0:192.168.100.101]  ol926ain2[enp3s0:192.168.100.102]  sim                       

    Origem                      Destino                     Conectado?                
    --------------------------  --------------------------  --------------------------
    ol926ain1[enp3s0:169.254.6.91]  ol926ain2[enp3s0:169.254.9.106]  sim                       
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
    Path "/u01/app/grid/diag/crs/ol926ain1/crs/metadata" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol926ain1/crs/lck" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol926ain1/crs/log" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol926ain1/crs/trace" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol926ain1/crs/cdump" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol926ain1/crs/metadata_pv" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol926ain1/crs/alert" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol926ain1/crs/sweep" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol926ain1/crs/stage" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol926ain1/crs/metadata_dgif" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol926ain1/crs/incpkg" ...APROVADO
    Path "/u01/app/grid/diag/crs/ol926ain1/crs/incident" ...APROVADO
    Path "/u01/app/23.7.0/grid/gpnp/wallets/peer/cwallet.sso" ...APROVADO
    Path "/u01/app/23.7.0/grid/gpnp/wallets/root/ewallet.p12" ...APROVADO
    Path "/u01/app/23.7.0/grid/gpnp/profiles/peer/profile.xml" ...APROVADO
    Path existence, ownership, permissions and attributes ...APROVADO
    Integridade de Gerenciador de Cluster ...
    Nome do Nó                            Status                  
    ------------------------------------  ------------------------
    ol926ain1                                 em execução             
    ol926ain2                                 em execução             
    Integridade de Gerenciador de Cluster ...APROVADO
    Máscara do Usuário ...
    Nome do Nó    Disponível                Necessário                Comentário
    ------------  ------------------------  ------------------------  ----------
    ol926ain2         0022                      0022                      aprovado  
    ol926ain1         0022                      0022                      aprovado  
    Máscara do Usuário ...APROVADO
    Integridade de Cluster ...
    Nome do Nó                          
    ------------------------------------
    ol926ain1                               
    ol926ain2                               
    Integridade de Cluster ...APROVADO
    Integridade do OCR ...APROVADO
    Integridade CRS ...
    Consistência da Versão do Clusterware ...APROVADO
    Integridade CRS ...APROVADO
    Existência de Aplicativo de Nó ...
    
    Verificando a existência do aplicativo de nó VIP (obrigatório)

    Nome do Nó    Necessário                Em execução?              Comentário
    ------------  ------------------------  ------------------------  ----------
    ol926ain1         sim                       sim                       aprovado  
    ol926ain2         sim                       sim                       aprovado  

    Verificando a existência do aplicativo de nó NETWORK (obrigatório)

    Nome do Nó    Necessário                Em execução?              Comentário
    ------------  ------------------------  ------------------------  ----------
    ol926ain1         sim                       sim                       aprovado  
    ol926ain2         sim                       sim                       aprovado  

    Verificando a existência do aplicativo de nó ONS (opcional)

    Nome do Nó    Necessário                Em execução?              Comentário
    ------------  ------------------------  ------------------------  ----------
    ol926ain1         não                       sim                       aprovado  
    ol926ain2         não                       sim                       aprovado  
    
    Existência de Aplicativo de Nó ...APROVADO
    SCAN ("Single Client Access Name", Nome de Acesso de Cliente Único) ...
    Nome do SCAN      Nó            Em execução?  ListenerName  Porta         Em execução?
    ----------------  ------------  ------------  ------------  ------------  ------------
    ol9n-scan         ol926ain1         true          LISTENER_SCAN1  1521          true        
    ol9n-scan         ol926ain1         true          LISTENER_SCAN2  1521          true        
    ol9n-scan         ol926ain1         true          LISTENER_SCAN3  1521          true        
    ol9n-scan         ol926ain2         true          LISTENER_SCAN4  1521          true        

    Verificando a conectividade TCP com os listeners SCAN...

    Nó            ListenerName              Conectividade do TCP?   
    ------------  ------------------------  ------------------------
    ol926ain1         LISTENER_SCAN1            sim                     
    ol926ain1         LISTENER_SCAN2            sim                     
    ol926ain1         LISTENER_SCAN3            sim                     
    ol926ain1         LISTENER_SCAN4            sim                     

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
    ol926ain1                                 sim                     
    ol926ain2                                 sim                     
  
    Integridade de ASM ...APROVADO
    ASM Network ...APROVADO
    Espaço livre do grupo de discos do ASM ...APROVADO
    O Usuário Não Está no Grupo "root": grid ...
    Nome do Nó    Status                    Comentário              
    ------------  ------------------------  ------------------------
    ol926ain2         aprovado                  não existe              
    ol926ain1         aprovado                  não existe              
  
    O Usuário Não Está no Grupo "root": grid ...APROVADO
    Sincronização do Relógio ...
    NTP (Network Time Protocol) ...
    Daemon 'chronyd' ...
    Nome do Nó                            Em execução?            
    ------------------------------------  ------------------------
    ol926ain2                                 sim                     
    ol926ain1                                 sim                     

    Daemon 'chronyd' ...APROVADO
    Daemon ou serviço NTP usando a porta UDP 123 ...
    Nome do Nó                            Porta Aberta?           
    ------------------------------------  ------------------------
    ol926ain2                                 sim                     
    ol926ain1                                 sim                     

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
    ol926ain2         psmisc-23.4-3.el9         psmisc-22.6-19            aprovado  
    ol926ain1         psmisc-23.4-3.el9         psmisc-22.6-19            aprovado  
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
    [grid@ol926ain1 ~]$ exit

###### CHECK CLUSTER STATUS ( CRSCTL )

    [grid@ol926ain1 ~]$ /u01/app/23.7.0/grid/bin/crsctl check cluster -all
    **************************************************************
    ol926ain1:
    CRS-4537: Cluster Ready Services is online
    CRS-4529: Cluster Synchronization Services is online
    CRS-4533: Event Manager is online
    **************************************************************
    ol926ain2:
    CRS-4537: Cluster Ready Services is online
    CRS-4529: Cluster Synchronization Services is online
    CRS-4533: Event Manager is online
    **************************************************************

    [grid@ol926ain1 ~]$ /u01/app/23.7.0/grid/bin/crsctl stat res -t 
    --------------------------------------------------------------------------------
    Name           Target  State        Server                   State details       
    --------------------------------------------------------------------------------
    Local Resources
    --------------------------------------------------------------------------------
    ora.LISTENER.lsnr
               ONLINE  ONLINE       ol926ain1                    STABLE
               ONLINE  ONLINE       ol926ain2                    STABLE
    ora.chad
               ONLINE  ONLINE       ol926ain1                    STABLE
               ONLINE  ONLINE       ol926ain2                    STABLE
    ora.helper
               OFFLINE OFFLINE      ol926ain1                    STABLE
               OFFLINE OFFLINE      ol926ain2                    IDLE,STABLE
    ora.net1.network
               ONLINE  ONLINE       ol926ain1                    STABLE
               ONLINE  ONLINE       ol926ain2                    STABLE
    ora.ons
               ONLINE  ONLINE       ol926ain1                    STABLE
               ONLINE  ONLINE       ol926ain2                    STABLE
    --------------------------------------------------------------------------------
    Cluster Resources
    --------------------------------------------------------------------------------
    ora.ASMNET1LSNR_ASM.lsnr(ora.asmgroup)
      1        ONLINE  ONLINE       ol926ain1                    STABLE
      2        ONLINE  ONLINE       ol926ain2                    STABLE
    ora.DATA.dg(ora.asmgroup)
      1        ONLINE  ONLINE       ol926ain1                    STABLE
      2        ONLINE  ONLINE       ol926ain2                    STABLE
    ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       ol926ain1                    STABLE
    ora.LISTENER_SCAN2.lsnr
      1        ONLINE  ONLINE       ol926ain1                    STABLE
    ora.LISTENER_SCAN3.lsnr
      1        ONLINE  ONLINE       ol926ain1                    STABLE
    ora.LISTENER_SCAN4.lsnr
      1        ONLINE  ONLINE       ol926ain2                    STABLE
    ora.asm(ora.asmgroup)
      1        ONLINE  ONLINE       ol926ain1                    Started,STABLE
      2        ONLINE  ONLINE       ol926ain2                    Started,STABLE
    ora.asmnet1.asmnetwork(ora.asmgroup)
      1        ONLINE  ONLINE       ol926ain1                    STABLE
      2        ONLINE  ONLINE       ol926ain2                    STABLE
    ora.cdp1.cdp
      1        ONLINE  ONLINE       ol926ain1                    STABLE
    ora.cdp2.cdp
      1        ONLINE  ONLINE       ol926ain1                    STABLE
    ora.cdp3.cdp
      1        ONLINE  ONLINE       ol926ain1                    STABLE
    ora.cdp4.cdp
      1        ONLINE  ONLINE       ol926ain2                    STABLE
    ora.cvu
      1        ONLINE  ONLINE       ol926ain1                    STABLE
    ora.ol926ain1.vip
      1        ONLINE  ONLINE       ol926ain1                    STABLE
    ora.ol926ain2.vip
      1        ONLINE  ONLINE       ol926ain2                    STABLE
    ora.rhpserver
      1        OFFLINE OFFLINE                               STABLE
    ora.scan1.vip
      1        ONLINE  ONLINE       ol926ain1                    STABLE
    ora.scan2.vip
      1        ONLINE  ONLINE       ol926ain1                    STABLE
    ora.scan3.vip
      1        ONLINE  ONLINE       ol926ain1                    STABLE
    ora.scan4.vip
      1        ONLINE  ONLINE       ol926ain2                    STABLE
    --------------------------------------------------------------------------------
    [grid@ol926ain1 ~]$ exit

    [root@ol926ain1 ~]# export ORACLE_HOME=/u01/app/23.7.0/grid
    [root@ol926ain1 ~]# export PATH=$PATH:$ORACLE_HOME/bin
    [root@ol926ain1 ~]# crsctl status resource
    NAME=ora.ASMNET1LSNR_ASM.lsnr(ora.asmgroup)
    TYPE=ora.asm_listener.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol926ain1, ONLINE on ol926ain2

    NAME=ora.DATA.dg(ora.asmgroup)
    TYPE=ora.diskgroup.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol926ain1, ONLINE on ol926ain2

    NAME=ora.LISTENER.lsnr
    TYPE=ora.listener.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol926ain1, ONLINE on ol926ain2

    NAME=ora.LISTENER_SCAN1.lsnr
    TYPE=ora.scan_listener.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain1

    NAME=ora.LISTENER_SCAN2.lsnr
    TYPE=ora.scan_listener.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain1

    NAME=ora.LISTENER_SCAN3.lsnr
    TYPE=ora.scan_listener.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain1

    NAME=ora.LISTENER_SCAN4.lsnr
    TYPE=ora.scan_listener.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain2

    NAME=ora.asm(ora.asmgroup)
    TYPE=ora.asm.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol926ain1, ONLINE on ol926ain2

    NAME=ora.asmnet1.asmnetwork(ora.asmgroup)
    TYPE=ora.asm_network.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol926ain1, ONLINE on ol926ain2

    NAME=ora.cdp1.cdp
    TYPE=ora.cdp.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain1

    NAME=ora.cdp2.cdp
    TYPE=ora.cdp.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain1

    NAME=ora.cdp3.cdp
    TYPE=ora.cdp.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain1

    NAME=ora.cdp4.cdp
    TYPE=ora.cdp.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain2

    NAME=ora.chad
    TYPE=ora.chad.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol926ain1, ONLINE on ol926ain2

    NAME=ora.cvu
    TYPE=ora.cvu.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain1

    NAME=ora.helper
    TYPE=ora.helper.type
    TARGET=OFFLINE, OFFLINE
    STATE=OFFLINE, OFFLINE

    NAME=ora.net1.network
    TYPE=ora.network.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol926ain1, ONLINE on ol926ain2

    NAME=ora.ol926ain1.vip
    TYPE=ora.cluster_vip_net1.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain1

    NAME=ora.ol926ain2.vip
    TYPE=ora.cluster_vip_net1.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain2

    NAME=ora.ons
    TYPE=ora.ons.type
    TARGET=ONLINE         , ONLINE
    STATE=ONLINE on ol926ain1, ONLINE on ol926ain2

    NAME=ora.rhpserver
    TYPE=ora.rhpserver.type
    TARGET=OFFLINE
    STATE=OFFLINE

    NAME=ora.scan1.vip
    TYPE=ora.scan_vip.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain1

    NAME=ora.scan2.vip
    TYPE=ora.scan_vip.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain1

    NAME=ora.scan3.vip
    TYPE=ora.scan_vip.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain1

    NAME=ora.scan4.vip
    TYPE=ora.scan_vip.type
    TARGET=ONLINE
    STATE=ONLINE on ol926ain2

###### CREATE DISKGRUOP FRA ON ASM ( ASMCA )

    [grid@ol926ain1 ~]$ asmca -silent -createDiskGroup -diskGroupName FRA -disk '/dev/asm-disk5' -redundancy EXTERNAL -au_size 4 -compatible.asm 23.0.0 -compatible.rdbms 19.0.0

###### COPY GRID INFRASTRUCTURE SOFTWARE

    [root@exated Downloads]# scp p37370465_230000_Linux-x86-64.zip oracle@192.168.18.121:/u01/app/oracle/product/23.7.0/dbhome_1/

###### UNZIP GRID INFRASTRUCTURE SOFTWARE

    [root@ol926ain1 ~]# su - oracle
    [oracle@ol926ain1 ~]$ cd /u01/app/oracle/product/23.7.0/dbhome_1/
    [oracle@ol926ain1 dbhome_1]$ unzip p37370465_230000_Linux-x86-64.zip
    [oracle@ol926ain1 dbhome_1]$ rm -vf p37370465_230000_Linux-x86-64.zip

###### INSTALL ORACLE DATABASE 26AI SOFTWARE 

     [root@ol926ain1 ~]# su - oracle 

###### CREATE A DATABASE RESPONSE FILE 

    [oracle@ol926ain1 ~]$ vi /home/oracle/dbca.rsp
    responseFileVersion=/oracle/assistants/rspfmt_dbca_response_schema_v23.0.0
    gdbName=oradbc.appsdba.info
    sid=oradbc
    databaseConfigType=RAC
    RACOneNodeServiceName=
    sehaServiceName=
    policyManaged=false
    managementPolicy=AUTOMATIC
    createServerPool=false
    serverPoolName=
    cardinality=
    force=false
    pqPoolName=
    pqCardinality=
    createAsContainerDatabase=true
    numberOfPDBs=1
    pdbName=pdboradbc
    useLocalUndoForPDBs=true
    pdbAdminPassword=
    nodelist=ol926ain1,ol926ain2
    sehaNodeList=
    templateName=/u01/app/oracle/product/23.7.0/dbhome_1/assistants/dbca/templates/General_Purpose.dbc
    sysPassword=
    systemPassword= 
    serviceUserPassword=
    emConfiguration=
    runCVUChecks=TRUE
    dbsnmpPassword=
    omsHost=
    omsPort=0
    emUser=
    emPassword=
    dvConfiguration=false
    dvUserName=
    dvUserPassword=
    dvAccountManagerName=
    dvAccountManagerPassword=
    olsConfiguration=false
    datafileJarLocation={ORACLE_HOME}/assistants/dbca/templates/
    datafileDestination=+DATA/{DB_UNIQUE_NAME}/
    recoveryAreaDestination=+FRA
    recoveryAreaSize=20200MB
	configureWithOID=
    pdbOptions=SAMPLE_SCHEMA:false,ORACLE_TEXT:true,OMS:true,CWMLITE:true,JSERVER:true,IMEDIA:false,SPATIAL:true,DV:true
    dbOptions=SAMPLE_SCHEMA:false,ORACLE_TEXT:true,OMS:true,CWMLITE:true,JSERVER:true,IMEDIA:false,SPATIAL:true,DV:true
    storageType=ASM
    diskGroupName=+DATA/{DB_UNIQUE_NAME}/
    asmsnmpPassword=
    recoveryGroupName=+FRA
    characterSet=AL32UTF8
    nationalCharacterSet=AL16UTF16
    registerWithDirService=false
    dirServiceUserName=
    dirServicePassword=
    walletPassword=
    listeners=LISTENER
    skipListenerRegistration=false
    variablesFile=
    variables=ORACLE_BASE_HOME=/u01/app/oracle/product/23.7.0/dbhome_1,DB_UNIQUE_NAME=oradbc,ORACLE_BASE=/u01/app/oracle,PDB_NAME=,DB_NAME=oradbc,ORACLE_HOME=/u01/app/oracle/product/23.7.0/dbhome_1,SID=oradbc
    initParams=oradbc1.undo_tablespace=UNDOTBS1,oradbc2.undo_tablespace=UNDOTBS2,enable_pluggable_database=true,sga_target=1788MB,db_block_size=8192BYTES,cluster_database=true,family:dw_helper.instance_mode=read-only,nls_language=BRAZILIAN PORTUGUESE,dispatchers=(PROTOCOL=TCP) (SERVICE=oradbcXDB),diagnostic_dest={ORACLE_BASE},remote_login_passwordfile=exclusive,db_create_file_dest=+DATA/{DB_UNIQUE_NAME}/,processes=300,pga_aggregate_target=597MB,oradbc1.thread=1,oradbc2.thread=2,nls_territory=BRAZIL,local_listener=-oraagent-dummy-,db_recovery_file_dest_size=20200MB,open_cursors=300,log_archive_format=%t_%s_%r.dbf,db_domain=appsdba.info,compatible=23.6.0,db_name=oradbc,oradbc1.instance_number=1,oradbc2.instance_number=2,db_recovery_file_dest=+FRA,_exadata_feature_on=true
    enableArchive=true
    useOMF=true
    memoryPercentage=40
    databaseType=MULTIPURPOSE
    automaticMemoryManagement=false
    totalMemory=0
    
###### CREATE ORACLE DATABASE IN SILENT MODE ( DBCA )

    [oracle@ol926ain1 ~]$ dbca -silent -createDatabase -responseFile /home/oracle/dbca.rsp
    Informe a senha do usuário SYS: 

    Informe a senha do usuário SYSTEM: 

    Informe a senha do usuário DBSNMP: 

    Informe a Senha do Usuário PDBADMIN: 

    [WARNING] [DBT-06208] A senha 'SYS' informada não está de acordo com os padrões recomendados pela Oracle.
    CAUSA: 
    a. A Oracle recomenda que a senha informada deve ter, pelo menos, 8 caracteres, deve conter, no mínimo, 1 caractere maiúsculo, 1 caractere minúsculo e 1 dígito [0-9].
    b. A senha informada é uma palavra-chave cuja utilização a Oracle não recomenda
    AÇÃO: Especifique uma senha complexa. Se for necessário, consulte a documentação da Oracle para obter orientações.
    [WARNING] [DBT-06208] A senha 'SYSTEM' informada não está de acordo com os padrões recomendados pela Oracle.
    CAUSA: 
    a. A Oracle recomenda que a senha informada deve ter, pelo menos, 8 caracteres, deve conter, no mínimo, 1 caractere maiúsculo, 1 caractere minúsculo e 1 dígito [0-9].
    b. A senha informada é uma palavra-chave cuja utilização a Oracle não recomenda
    AÇÃO: Especifique uma senha complexa. Se for necessário, consulte a documentação da Oracle para obter orientações.
    [WARNING] [DBT-06208] A senha 'PDBADMIN' informada não está de acordo com os padrões recomendados pela Oracle.
    CAUSA: 
    a. A Oracle recomenda que a senha informada deve ter, pelo menos, 8 caracteres, deve conter, no mínimo, 1 caractere maiúsculo, 1 caractere minúsculo e 1 dígito [0-9].
    b. A senha informada é uma palavra-chave cuja utilização a Oracle não recomenda
    AÇÃO: Especifique uma senha complexa. Se for necessário, consulte a documentação da Oracle para obter orientações.
    [WARNING] [DBT-06208] A senha 'DBSNMP' informada não está de acordo com os padrões recomendados pela Oracle.
    CAUSA: 
    a. A Oracle recomenda que a senha informada deve ter, pelo menos, 8 caracteres, deve conter, no mínimo, 1 caractere maiúsculo, 1 caractere minúsculo e 1 dígito [0-9].
    b. A senha informada é uma palavra-chave cuja utilização a Oracle não recomenda
    AÇÃO: Especifique uma senha complexa. Se for necessário, consulte a documentação da Oracle para obter orientações.   
    [WARNING] [DBT-09102] O ambiente de destino não atende a alguns requisitos opcionais.
    CAUSA: Alguns dos pré-requisitos opcionais não foram atendidos. Consulte os detalhes nos logs.
    AÇÃO: Encontre a configuração apropriada no arquivo de log ou no guia de instalação para atender aos pré-requisitos e corrigir isso manualmente.
    Preparar para operação de bd
    7% concluído
    Copiando arquivos de banco de dados
    27% concluído
    Criando e iniciando a instância Oracle
    28% concluído
    31% concluído
    33% concluído
    36% concluído
    40% concluído
    Criando views do banco de dados do cluster
    41% concluído
    53% concluído
    Concluindo Criação de Banco de Dados
    57% concluído
    59% concluído
    60% concluído
    Criando Bancos de Dados Plugáveis
    64% concluído
    80% concluído
    Executando Ações Pós-configuração
    100% concluído
    Criação do banco de dados concluída. Para obter detalhes, verifique os arquivos de log em:
     /u01/app/oracle/cfgtoollogs/dbca/oradbc.
    Informações sobre o Banco de Dados:
    Nome do Banco de Dados Global:oradbc.appsdba.info
    Prefixo do Identificador de Sistema (SID):oradbc
    Verifique o arquivo de log "/u01/app/oracle/cfgtoollogs/dbca/oradbc/oradbc.log" para obter mais detalhes.

###### CHECK POST DATABASE CREATION

    [oracle@ol926ain1 ~]$ ps -ef | grep pmon
    grid       40049    1566  0 mar01 ?        00:00:00 asm_pmon_+ASM1
    oracle    220203    1566  0 00:48 ?        00:00:00 ora_pmon_oradbc1

    [oracle@ol926ain2 ~]$ ps -ef | grep pmon
    grid       46177       1  0 mar01 ?        00:00:00 asm_pmon_+ASM2
    oracle    193366       1  0 00:48 ?        00:00:00 ora_pmon_oradbc2

###### STOP CLUSTER AND DATABASE 

	[root@ol926ain1 ~]# crsctl stop cluster -all
	CRS-2673: Tentativa de interromper 'ora.crsd' em 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.crsd' em 'ol926ain2'
	CRS-2790: Iniciando o shutdown de recursos gerenciados pelo Cluster Ready Services no servidor 'ol926ain2'
	CRS-2673: Tentativa de interromper 'ora.chad' em 'ol926ain2'
	CRS-2673: Tentativa de interromper 'ora.oradbc.oradbc_pdboradbc.svc' em 'ol926ain2'
	CRS-2673: Tentativa de interromper 'ora.cdp4.cdp' em 'ol926ain2'
	CRS-2790: Iniciando o shutdown de recursos gerenciados pelo Cluster Ready Services no servidor 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.cdp1.cdp' em 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.cdp2.cdp' em 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.oradbc.oradbc_pdboradbc.svc' em 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.cdp3.cdp' em 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.chad' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.cdp4.cdp' em 'ol926ain2' bem-sucedida
	CRS-2677: Interrupção de 'ora.oradbc.oradbc_pdboradbc.svc' em 'ol926ain2' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.oradbc.pdboradbc.pdb' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.cdp1.cdp' em 'ol926ain1' bem-sucedida
	CRS-2677: Interrupção de 'ora.cdp2.cdp' em 'ol926ain1' bem-sucedida
	CRS-2677: Interrupção de 'ora.oradbc.pdboradbc.pdb' em 'ol926ain2' bem-sucedida
	CRS-2677: Interrupção de 'ora.cdp3.cdp' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.oradbc.db' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.oradbc.oradbc_pdboradbc.svc' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.oradbc.pdboradbc.pdb' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.oradbc.pdboradbc.pdb' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.oradbc.db' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.oradbc.db' em 'ol926ain2' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.LISTENER.lsnr' em 'ol926ain2'
	CRS-2673: Tentativa de interromper 'ora.LISTENER_SCAN4.lsnr' em 'ol926ain2'
	CRS-33673: Tentando interromper o grupo de recursos 'ora.asmgroup' no servidor 'ol926ain2'
	CRS-2673: Tentativa de interromper 'ora.DATA.dg' em 'ol926ain2'
	CRS-2673: Tentativa de interromper 'ora.FRA.dg' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.DATA.dg' em 'ol926ain2' bem-sucedida
	CRS-2677: Interrupção de 'ora.FRA.dg' em 'ol926ain2' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.asm' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.asm' em 'ol926ain2' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.ASMNET1LSNR_ASM.lsnr' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.LISTENER.lsnr' em 'ol926ain2' bem-sucedida
	CRS-2677: Interrupção de 'ora.LISTENER_SCAN4.lsnr' em 'ol926ain2' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.ol926ain2.vip' em 'ol926ain2'
	CRS-2673: Tentativa de interromper 'ora.scan4.vip' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.ol926ain2.vip' em 'ol926ain2' bem-sucedida
	CRS-2677: Interrupção de 'ora.ASMNET1LSNR_ASM.lsnr' em 'ol926ain2' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.asmnet1.asmnetwork' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.asmnet1.asmnetwork' em 'ol926ain2' bem-sucedida
	CRS-33677: A interrupção do grupo de recursos 'ora.asmgroup' no servidor 'ol926ain2' foi bem-sucedida.
	CRS-2677: Interrupção de 'ora.scan4.vip' em 'ol926ain2' bem-sucedida
	CRS-2677: Interrupção de 'ora.oradbc.db' em 'ol926ain1' bem-sucedida
	CRS-2677: Interrupção de 'ora.chad' em 'ol926ain2' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.LISTENER.lsnr' em 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.LISTENER_SCAN1.lsnr' em 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.LISTENER_SCAN2.lsnr' em 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.LISTENER_SCAN3.lsnr' em 'ol926ain1'
	CRS-33673: Tentando interromper o grupo de recursos 'ora.asmgroup' no servidor 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.DATA.dg' em 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.FRA.dg' em 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.cvu' em 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.ons' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.DATA.dg' em 'ol926ain1' bem-sucedida
	CRS-2677: Interrupção de 'ora.chad' em 'ol926ain1' bem-sucedida
	CRS-2677: Interrupção de 'ora.cvu' em 'ol926ain1' bem-sucedida
	CRS-2677: Interrupção de 'ora.FRA.dg' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.asm' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.asm' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.ASMNET1LSNR_ASM.lsnr' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.ons' em 'ol926ain2' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.net1.network' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.net1.network' em 'ol926ain2' bem-sucedida
	CRS-2792: O shut-down de recursos gerenciados pelo Cluster Ready Services em 'ol926ain2' foi concluído
	CRS-2677: Interrupção de 'ora.LISTENER.lsnr' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.ol926ain1.vip' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.LISTENER_SCAN3.lsnr' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.scan3.vip' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.LISTENER_SCAN1.lsnr' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.scan1.vip' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.LISTENER_SCAN2.lsnr' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.scan2.vip' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.ASMNET1LSNR_ASM.lsnr' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.asmnet1.asmnetwork' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.asmnet1.asmnetwork' em 'ol926ain1' bem-sucedida
	CRS-33677: A interrupção do grupo de recursos 'ora.asmgroup' no servidor 'ol926ain1' foi bem-sucedida.
	CRS-2677: Interrupção de 'ora.ol926ain1.vip' em 'ol926ain1' bem-sucedida
	CRS-2677: Interrupção de 'ora.scan3.vip' em 'ol926ain1' bem-sucedida
	CRS-2677: Interrupção de 'ora.scan1.vip' em 'ol926ain1' bem-sucedida
	CRS-2677: Interrupção de 'ora.scan2.vip' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.ons' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.crsd' em 'ol926ain2' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.evmd' em 'ol926ain2'
	CRS-2673: Tentativa de interromper 'ora.storage' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.storage' em 'ol926ain2' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.asm' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.ons' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.net1.network' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.net1.network' em 'ol926ain1' bem-sucedida
	CRS-2792: O shut-down de recursos gerenciados pelo Cluster Ready Services em 'ol926ain1' foi concluído
	CRS-2677: Interrupção de 'ora.evmd' em 'ol926ain2' bem-sucedida
	CRS-2677: Interrupção de 'ora.crsd' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.evmd' em 'ol926ain1'
	CRS-2673: Tentativa de interromper 'ora.storage' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.storage' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.asm' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.evmd' em 'ol926ain1' bem-sucedida
	CRS-2677: Interrupção de 'ora.asm' em 'ol926ain2' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.cluster_interconnect.haip' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.cluster_interconnect.haip' em 'ol926ain2' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.cssd' em 'ol926ain2'
	CRS-2677: Interrupção de 'ora.asm' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.cluster_interconnect.haip' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.cssd' em 'ol926ain2' bem-sucedida
	CRS-2677: Interrupção de 'ora.cluster_interconnect.haip' em 'ol926ain1' bem-sucedida
	CRS-2673: Tentativa de interromper 'ora.cssd' em 'ol926ain1'
	CRS-2677: Interrupção de 'ora.cssd' em 'ol926ain1' bem-sucedida

	[root@ol926ain1 ~]# crsctl stop has
	CRS-2791: Starting shutdown of Oracle High Availability Services-managed resources on 'ol926ain1'
	CRS-2673: Attempting to stop 'ora.gpnpd' on 'ol926ain1'
	CRS-2673: Attempting to stop 'ora.crf' on 'ol926ain1'
	CRS-2673: Attempting to stop 'ora.mdnsd' on 'ol926ain1'
	CRS-2673: Attempting to stop 'ora.drivers.acfs' on 'ol926ain1'
	CRS-2677: Stop of 'ora.gpnpd' on 'ol926ain1' succeeded
	CRS-2677: Stop of 'ora.crf' on 'ol926ain1' succeeded
	CRS-2673: Attempting to stop 'ora.gipcd' on 'ol926ain1'
	CRS-2677: Stop of 'ora.gipcd' on 'ol926ain1' succeeded
	CRS-2677: Stop of 'ora.drivers.acfs' on 'ol926ain1' succeeded
	CRS-2677: Stop of 'ora.mdnsd' on 'ol926ain1' succeeded
	CRS-2793: Shutdown of Oracle High Availability Services-managed resources on 'ol926ain1' has completed
	CRS-4133: Oracle High Availability Services has been stopped.

	[root@ol926ain2 ~]# crsctl stop has
	CRS-2791: Starting shutdown of Oracle High Availability Services-managed resources on 'ol926ain2'
	CRS-2673: Attempting to stop 'ora.crf' on 'ol926ain2'
	CRS-2673: Attempting to stop 'ora.drivers.acfs' on 'ol926ain2'
	CRS-2673: Attempting to stop 'ora.gpnpd' on 'ol926ain2'
	CRS-2673: Attempting to stop 'ora.mdnsd' on 'ol926ain2'
	CRS-2677: Stop of 'ora.gpnpd' on 'ol926ain2' succeeded
	CRS-2677: Stop of 'ora.drivers.acfs' on 'ol926ain2' succeeded
	CRS-2677: Stop of 'ora.crf' on 'ol926ain2' succeeded
	CRS-2673: Attempting to stop 'ora.gipcd' on 'ol926ain2'
	CRS-2677: Stop of 'ora.gipcd' on 'ol926ain2' succeeded
	CRS-2677: Stop of 'ora.mdnsd' on 'ol926ain2' succeeded
	CRS-2793: Shutdown of Oracle High Availability Services-managed resources on 'ol926ain2' has completed
	CRS-4133: Oracle High Availability Services has been stopped.

###### writed by: Danilo Arruda
###### sat 03 mar 2025

