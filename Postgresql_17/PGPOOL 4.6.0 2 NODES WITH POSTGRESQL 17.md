**PGPOOL 4.6.0 2 NODES WITH POSTGRESQL 17**

> *The main purpose of installing PostgreSQL 17 is to provide a robust, reliable, open-source relational database management system (RDBMS) for a variety of applications.
> *- Data management: PostgreSQL enables you to store, organize, and manage large volumes of data efficiently and securely.*  
> *- Diverse applications: It is suitable for a wide range of applications, from small personal projects to large enterprise systems, including web, mobile, data analysis, and scientific applications.*    
> *- Advanced features: PostgreSQL offers advanced features such as transactional integrity (ACID), concurrency, replication, security, and extensibility, making it a popular choice for mission-critical applications.*    
> *- Community and support: As an open source project, PostgreSQL has an active community of developers and users, which ensures ongoing support, updates, and improvements.*    
> *- Updates and improvements: Postgres 17 brings with it performance and security improvements over previous versions.*

![oracle database 23ai logo.](https://github.com/danilo01arrudal/Exated/blob/main/Postgresql_17/images/PgpoolII.jpg)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER (NODE 1)

    [root@exated ~]# virt-install --virt-type kvm --name ol9pg1 --memory 4096 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9pg1.qcow2,size=50

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER (NODE 2)

    [root@exated ~]# virt-install --virt-type kvm --name ol9pg2 --memory 4096 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9pg2.qcow2,size=50

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( CONFIGURE HOSTNAME NODE 1)

    [root@ol9pg1 ~]# hostnamectl set-hostname ol9pg1.appsdba.info

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( CONFIGURE HOSTNAME NODE 2)

    [root@ol9pg2 ~]# hostnamectl set-hostname ol9pg2.appsdba.info

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( CONFIGURE STATIC NETWORK NODE 1)

    [root@ol9pg1 ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  connected               enp1s0     
    enp2s0  ethernet  connected               enp2s0     
    lo      loopback  connected (externally)  lo   
    [root@ol9pg1 ~]# nmcli connection show  
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  55828ae7-7fcb-371b-9b1a-07a34fe1fb43  ethernet  enp1s0 
    enp2s0  f5c06f41-c649-35c3-9bb7-3e90849ee116  ethernet  enp2s0 
    lo      c528b3cb-aa9b-4fde-abee-2d94ba34d29d  loopback  lo
    [root@ol9pg1 ~]# nmcli con modify 'enp1s0' ifname enp1s0 ipv4.method manual ipv4.addresses 192.168.18.231/24 ipv4.gateway 192.168.18.1 autoconnect yes ipv6.method disabled
    [root@ol9pg1 ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.201 
    [root@ol9pg1 ~]# nmcli con down 'enp1s0'; nmcli con up 'enp1s0' 
    Connection 'enp1s0' successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/2)
    Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/4)
    [root@ol9pg1 ~]# ip addr show enp1s0
    2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:8a:76:62 brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.231/24 brd 192.168.18.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever
    [root@ol9pg1 ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  connected               enp1s0     
    enp2s0  ethernet  connected               enp2s0     
    lo      loopback  connected (externally)  lo         
    [root@ol9pg1 ~]# nmcli connection show
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  55828ae7-7fcb-371b-9b1a-07a34fe1fb43  ethernet  enp1s0 
    enp2s0  f5c06f41-c649-35c3-9bb7-3e90849ee116  ethernet  enp2s0 
    lo      c528b3cb-aa9b-4fde-abee-2d94ba34d29d  loopback  lo 

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( CONFIGURE STATIC NETWORK NODE 2)

    [root@ol9pg2 ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  connected               enp1s0     
    enp2s0  ethernet  connected               enp2s0     
    lo      loopback  connected (externally)  lo         
    [root@ol9pg2 ~]# nmcli connection show  
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  8b80599e-c49e-3565-8c29-7ded0cec94e0  ethernet  enp1s0 
    enp2s0  1b65e7f2-8343-37a1-8c05-4628db7ce870  ethernet  enp2s0 
    lo      05478f0a-cadf-47d7-9d1f-82438b63541f  loopback  lo     
    [root@ol9pg2 ~]# nmcli con modify 'enp1s0' ifname enp1s0 ipv4.method manual ipv4.addresses 192.168.18.232/24 ipv4.gateway 192.168.18.1 autoconnect yes ipv6.method disabled
    [root@ol9pg2 ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.201 
    [root@ol9pg2 ~]# nmcli con down 'enp1s0'; nmcli con up 'enp1s0' 
    Connection 'enp1s0' successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/2)
    Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/4)
    [root@ol9pg2 ~]# ip addr show enp1s0
    2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:a1:05:a6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.232/24 brd 192.168.18.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever
    [root@ol9pg2 ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  connected               enp1s0     
    enp2s0  ethernet  connected               enp2s0     
    lo      loopback  connected (externally)  lo         
    [root@ol9pg2 ~]# nmcli connection show
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  8b80599e-c49e-3565-8c29-7ded0cec94e0  ethernet  enp1s0 
    enp2s0  1b65e7f2-8343-37a1-8c05-4628db7ce870  ethernet  enp2s0 
    lo      05478f0a-cadf-47d7-9d1f-82438b63541f  loopback  lo  

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( DISABLE AVAHI )

    [root@ol9pg1 ~]# systemctl disable avahi-daemon.socket avahi-daemon.service 
    Removed "/etc/systemd/system/multi-user.target.wants/avahi-daemon.service".
    Removed "/etc/systemd/system/sockets.target.wants/avahi-daemon.socket".
    Removed "/etc/systemd/system/dbus-org.freedesktop.Avahi.service".
    [root@ol9pg1 ~]# systemctl mask avahi-daemon.socket avahi-daemon.service 
    Created symlink /etc/systemd/system/avahi-daemon.socket → /dev/null.
    Created symlink /etc/systemd/system/avahi-daemon.service → /dev/null.
    [root@ol9pg1 ~]# systemctl stop avahi-daemon.socket avahi-daemon.service

    [root@ol9pg2 ~]# systemctl disable avahi-daemon.socket avahi-daemon.service
    Removed "/etc/systemd/system/multi-user.target.wants/avahi-daemon.service".
    Removed "/etc/systemd/system/dbus-org.freedesktop.Avahi.service".
    Removed "/etc/systemd/system/sockets.target.wants/avahi-daemon.socket".
    [root@ol9pg2 ~]# systemctl mask avahi-daemon.socket avahi-daemon.service 
    Created symlink /etc/systemd/system/avahi-daemon.socket → /dev/null.
    Created symlink /etc/systemd/system/avahi-daemon.service → /dev/null.
    [root@ol9pg2 ~]# systemctl stop avahi-daemon.socket avahi-daemon.service

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( FIREWALL AND SELINUX )

    [root@ol9pg1 ~]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    [root@ol9pg1 ~]# systemctl stop firewalld; systemctl disable firewalld

    [root@ol9pg2 ~]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    [root@ol9pg2 ~]# systemctl stop firewalld; systemctl disable firewalld 

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( DEFINE LOCALTIME )

    [root@ol9pg1 ~]# rm -vf /etc/localtime; ln -s /usr/share/zoneinfo/America/Fortaleza /etc/localtime

    [root@ol9pg2 ~]# rm -vf /etc/localtime; ln -s /usr/share/zoneinfo/America/Fortaleza /etc/localtime


###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( GRANT PERMISSIONS TO NETWORK BINARIES )

    [root@ol9pg1 ~]# chmod u+x /usr/sbin/ip; chmod u+s /usr/sbin/arping; chmod u+s /sbin/ip; chmod u+s /sbin/ifconfig

    [root@ol9pg2 ~]# chmod u+x /usr/sbin/ip; chmod u+s /usr/sbin/arping; chmod u+s /sbin/ip; chmod u+s /sbin/ifconfig


###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( PACKAGES )

    [root@ol9pg1 ~]# dnf config-manager --enable ol9_codeready_builder; pkill -f 'yum'; yum repolist; yum install -y net-tools openssl-devel rsync; yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm; yum install -y libmemcached-awesome-1.1.0-12.el9.x86_64 libmemcached-awesome-devel-1.1.0-12.el9.x86_64 libmemcached-awesome-tools-1.1.0-12.el9.x86_64; yum install -y postgresql17-contrib.x86_64 postgresql17-libs.x86_64 postgresql17-server.x86_64 postgresql17.x86_64; yum install -y pgpool-II-4.6.0-1PGDG.rhel9.x86_6 pgpool-II-pcp-4.6.0-1PGDG.rhel9.x86_64 pgpool-II-pg17-extensions-4.6.0-1PGDG.rhel9.x86_64

    [root@ol9pg2 ~]# dnf config-manager --enable ol9_codeready_builder; pkill -f 'yum'; yum repolist; yum install -y net-tools openssl-devel rsync; yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm; yum install -y libmemcached-awesome-1.1.0-12.el9.x86_64 libmemcached-awesome-devel-1.1.0-12.el9.x86_64 libmemcached-awesome-tools-1.1.0-12.el9.x86_64; yum install -y postgresql17-contrib.x86_64 postgresql17-libs.x86_64 postgresql17-server.x86_64 postgresql17.x86_64; yum install -y pgpool-II-4.6.0-1PGDG.rhel9.x86_64; yum install -y pgpool-II-pcp-4.6.0-1PGDG.rhel9.x86_64; yum install -y pgpool-II-pg17-extensions-4.6.0-1PGDG.rhel9.x86_64


###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( ENVIRONMENT VARIABLES )

    [root@ol9pg1 ~]# echo "PGDATA=/var/lib/pgsql/17/data/" >> /etc/environment
    [root@ol9pg1 ~]# echo "PGHOME=/usr/pgsql-17/" >> /etc/environment

    [root@ol9pg2 ~]# echo "PGDATA=/var/lib/pgsql/17/data/" >> /etc/environment
    [root@ol9pg2 ~]# echo "PGHOME=/usr/pgsql-17/" >> /etc/environment

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( POSTRGES PASSWORD )

    [root@ol9pg1 ~]# passwd postgres
    [root@ol9pg2 ~]# passwd postgres

###### SSH KEY EXCHANGE ( NODE 1 )

    [root@ol9pg1 ~]# su - postgres -c "ssh-keygen -t rsa"
    [root@ol9pg1 ~]# su - postgres -c "cat /var/lib/pgsql/.ssh/id_rsa.pub > /var/lib/pgsql/.ssh/authorized_keys"
    [root@ol9pg1 ~]# chmod 600 /var/lib/pgsql/.ssh/authorized_keys
    [root@ol9pg1 ~]# su - postgres
    [postgres@ol9pg1 ~]$ ssh-copy-id -i .ssh/id_rsa.pub postgres@ol9pg2

###### SSH KEY EXCHANGE ( NODE 2 )

    [root@ol9pg2 ~]# su - postgres -c "ssh-keygen -t rsa"
    [root@ol9pg2 ~]# su - postgres -c "cat /var/lib/pgsql/.ssh/id_rsa.pub > /var/lib/pgsql/.ssh/authorized_keys"
    [root@ol9pg2 ~]# chmod 600 /var/lib/pgsql/.ssh/authorized_keys
    [root@ol9pg2 ~]# su - postgres
    [postgres@ol9pg2 ~]$ ssh-copy-id -i .ssh/id_rsa.pub postgres@ol9pg1

###### PRE REQUIREMENTS PGPOOL-II ENVIRONMENT ( ENVIRONMENT FILE )

    [root@ol9pg1 ~]# cat > /etc/sysconfig/pgpool <<EOF
    # Options for pgpool

    # -n: don't run in daemon mode. does not detatch control tty
    # -d: debug mode. lots of debug information will be printed

    OPTS=" -d -n"
    #OPTS=" -n"

    STOP_OPTS=" -m fast"
    EOF
    [root@ol9pg1 ~]# chown postgres:postgres /etc/sysconfig/pgpool

    [root@ol9pg2 ~]# cat > /etc/sysconfig/pgpool <<EOF
    # Options for pgpool

    # -n: don't run in daemon mode. does not detatch control tty
    # -d: debug mode. lots of debug information will be printed

    OPTS=" -d -n"
    #OPTS=" -n"

    STOP_OPTS=" -m fast"
    EOF
    [root@ol9pg1 ~]# chown postgres:postgres /etc/sysconfig/pgpool

###### ENABLE PGPOOL-II AND POSTGRESQL-17

    [root@ol9pg1 ~]# systemctl daemon-reload; systemctl enable pgpool-II.service; systemctl daemon-reload; systemctl enable postgresql-17.service;
    [root@ol9pg2 ~]# systemctl daemon-reload; systemctl enable pgpool-II.service; systemctl daemon-reload; systemctl enable postgresql-17.service;

###### CREATE INSTANCE POSTGRESQL-17

    [root@ol9pg1 ~]# systemctl stop postgresql-17.service
    [root@ol9pg1 ~]# rm -Rvf /var/lib/pgsql/17/data/*;
    [root@ol9pg1 ~]# rm -Rvf /var/lib/pgsql/archivedir
    [root@ol9pg1 ~]# mkdir -p /var/lib/pgsql/archivedir
    [root@ol9pg1 ~]# chown postgres:postgres -R /var/lib/pgsql/archivedir
    [root@ol9pg1 ~]# echo "postgres"> /var/lib/pgsql/pdwfile
    [root@ol9pg1 ~]# chown postgres:postgres /var/lib/pgsql/pdwfile
    [root@ol9pg1 ~]# su - postgres -c "/usr/pgsql-17/bin/initdb -k -D /var/lib/pgsql/17/data/ --pwfile=/var/lib/pgsql/pdwfile --auth-host=md5"
    [root@ol9pg1 ~]# systemctl start postgresql-17.service;
    [root@ol9pg1 ~]# rm -vf /var/lib/pgsql/pdwfile
    [root@ol9pg1 ~]# echo *:5432:*:postgres:postgres > /var/lib/pgsql/.pgpass;
    [root@ol9pg1 ~]# chown postgres:postgres /var/lib/pgsql/.pgpass;
    [root@ol9pg1 ~]# chmod 0600 /var/lib/pgsql/.pgpass;
    [root@ol9pg1 ~]# rm -vf /home/postgres/useraccts.sql

###### BACKUP CONFIGURATION FILES ( POSTGRESQL-17 AND PGPOOL-II )

    [root@ol9pg1 ~]# cp -vf /var/lib/pgsql/17/data/postgresql.conf /var/lib/pgsql/17/data/postgresql.conf-bkp
    [root@ol9pg1 ~]# chown postgres:postgres /var/lib/pgsql/17/data/postgresql.conf-bkp
    [root@ol9pg1 ~]# cp /var/lib/pgsql/17/data/pg_hba.conf /var/lib/pgsql/17/data/pg_hba.conf-bkp
    [root@ol9pg1 ~]# chown postgres:postgres /var/lib/pgsql/17/data/pg_hba.conf-bkp

###### MODIFY CONFIGURATION FILES ( PGPOOL-II )

su - postgres -c "cp -vf /etc/pgpool-II/pgpool.conf.sample /etc/pgpool-II/pgpool.conf"; 
listen_addresses = '*'
socket_dir = '/var/run/postgresql' 
sed -e "/backend_hostname0/s/'.*'/'pg1'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "s/#backend_hostname1/backend_hostname1/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/backend_hostname1/s/'.*'/'pg2'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "s/#backend_port1/backend_port1/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/backend_port1/s/5433/5432/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "s/#backend_weight1/backend_weight1/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "s/#backend_data_directory1 =/backend_data_directory1 =/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/backend_data_directory1/s/'.*'/'\/var\/lib\/pgsql\/12\/data'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/backend_data_directory0/s/'.*'/'\/var\/lib\/pgsql\/12\/data'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "s/#backend_flag1/backend_flag1/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/sr_check_user =/s/'nobody'/'replication'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/sr_check_password =/s/''/'replication'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/health_check_period =/s/0/10/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/health_check_user =/s/'nobody'/'postgres'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/health_check_password =/s/''/'postgres'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/failover_command =/s/''/'\/etc\/pgpool-II\/failover.sh \%d \%h \%p \%D \%m \%H \%M \%P \%r \%R \%N \%S'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/recovery_user =/s/'nobody'/'postgres'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/recovery_password =/s/''/'postgres'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/recovery_1st_stage_command =/s/''/'recovery_1st_stage'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/use_watchdog =/s/off/on/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/delegate_IP =/s/''/'192.168.1.121'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/if_up_cmd =/s/'\/usr\/bin\/sudo \/sbin\/ip addr add \$_IP_\$\/24 dev eth0 label eth0\:0'/'\/usr\/bin\/sudo \/sbin\/ip addr add \$_IP_\$\/24 dev enp0s3 label enp0s3\:0'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/if_down_cmd =/s/'\/usr\/bin\/sudo \/sbin\/ip addr del \$_IP_\$\/24 dev eth0'/'\/usr\/bin\/sudo \/sbin\/ip addr del \$_IP_\$\/24 dev enp0s3'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/arping_cmd =/s/'\/usr\/bin\/sudo \/usr\/sbin\/arping -U \$_IP_\$ -w 1 -I eth0'/'\/usr\/bin\/sudo \/usr\/sbin\/arping -U \$_IP_\$ -w 1 -I enp0s3'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/wd_hostname =/s/''/'pg1'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "s/#other_pgpool_hostname0/other_pgpool_hostname0/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/other_pgpool_hostname0 =/s/'host0'/'pg2'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "s/#other_pgpool_port0/other_pgpool_port0/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; sed -e "/other_pgpool_port0 =/s/5432/9999/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "s/#other_wd_port0/other_wd_port0/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/heartbeat_destination0 =/s/'host0_ip1'/'pg2'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/heartbeat_device0 =/s/'.*'/'enp0s3'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/health_check_database =/s/''/'postgres'/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/load_balance_mode =/s/off/on/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/master_slave_mode =/s/off/on/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/sr_check_period =/s/0/5/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/allow_multiple_failover_requests_from_node =/s/off/on/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/enable_consensus_with_half_votes =/s/off/on/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
sed -e "/enable_consensus_with_half_votes =/s/off/on/" /etc/pgpool-II/pgpool.conf > /etc/pgpool-II/pgpool.conf-new; 
mv -vf /etc/pgpool-II/pgpool.conf-new /etc/pgpool-II/pgpool.conf; 
chown postgres:postgres /etc/pgpool-II/pgpool.conf; 
su - postgres -c "cp -vf /etc/pgpool-II/pool_hba.conf.sample /etc/pgpool-II/pool_hba.conf"; 
chown postgres:postgres -R /etc/pgpool-II; 
mkdir -p /var/log/pgpool/; 
chown postgres:postgres -R /var/log/pgpool;

    

    
