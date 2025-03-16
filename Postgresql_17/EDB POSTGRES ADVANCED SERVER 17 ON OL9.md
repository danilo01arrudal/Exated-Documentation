**EDB POSTGRES ADVANCED SERVER 17 ON OL9**

> *The main purpose of installing EDB PostgreSQL 17 is to provide a robust, reliable, open-source relational database management system (RDBMS) for a variety of applications.
> *- Data management: EDB PostgreSQL enables you to store, organize, and manage large volumes of data efficiently and securely.*  
> *- Diverse applications: It is suitable for a wide range of applications, from small personal projects to large enterprise systems, including web, mobile, data analysis, and scientific applications.*    
> *- Advanced features: EDB PostgreSQL offers advanced features such as transactional integrity (ACID), concurrency, replication, security, and extensibility, making it a popular choice for mission-critical applications.*    
> *- Community and support: As an open source project, PostgreSQL has an active community of developers and users, which ensures ongoing support, updates, and improvements.*    
> *- Updates and improvements: Postgres 17 brings with it performance and security improvements over previous versions.*

![edb postgres logo.](https://github.com/danilo01arrudal/Documentation/blob/main/Postgresql_17/images/edb_postgres.jpeg)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER 

    [root@exated ~]# virt-install --virt-type kvm --name ol9pgedb --memory 4096 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9pgedb.qcow2,size=50

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( DISABLE SELINUX ) 
   
    [root@ol9pgedb ~]# hostnamectl set-hostname ol9pgedb

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( CONFIGURE REPOSITORY )

    [root@ol9pgedb ~]# curl -1sSLf 'https://downloads.enterprisedb.com/********************************/enterprise/setup.rpm.sh' | sudo -E bash

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( VALIDATE REPOSITORY )

    [root@ol9pgedb ~]# yum repolist
    repo id                                                                                                      repo name
    enterprisedb-enterprise                                                                                      enterprisedb-enterprise
    enterprisedb-enterprise-noarch                                                                               enterprisedb-enterprise-noarch
    enterprisedb-enterprise-source                                                                               enterprisedb-enterprise-source
    ol9_UEKR7                                                                                                    Oracle Linux 9 UEK Release 7 (x86_64)
    ol9_appstream                                                                                                Oracle Linux 9 Application Stream Packages (x86_64)
    ol9_baseos_latest                                                                                            Oracle Linux 9 BaseOS Latest (x86_64)

###### INSTALL EDB POSTGRES ADVANCED SERVER 17
    
    [root@ol9pgedb ~]# dnf -y install edb-as17-server edb-edbplus.x86_64

###### POST INSTALL EDB POSTGRES ( CREATE DATABASE DEFAULT )

    [root@ol9pgedb ~]# PGSETUP_INITDB_OPTIONS="-E UTF-8" /usr/edb/as17/bin/edb-as-17-setup initdb
    Initializing database ... OK


###### POST INSTALL EDB POSTGRES ( START AND ENABLE EDB DAEMON ) 

    [root@ol9pgedb ~]# systemctl enable edb-as-17 
    Created symlink /etc/systemd/system/multi-user.target.wants/edb-as-17.service → /usr/lib/systemd/system/edb-as-17.service.

    [root@ol9pgedb ~]# systemctl start edb-as-17 

    [root@ol9pgedb ~]# systemctl status -l edb-as-17
    ● edb-as-17.service - EDB Postgres Advanced Server 17
     Loaded: loaded (/usr/lib/systemd/system/edb-as-17.service; enabled; preset: disabled)
     Active: active (running) since Sun 2025-03-16 12:14:08 -03; 2s ago
    Process: 13284 ExecStartPre=/usr/edb/as17/bin/edb-as-17-check-db-dir ${PGDATA} (code=exited, status=0/SUCCESS)
    Main PID: 13289 (edb-postgres)
      Tasks: 8 (limit: 24723)
     Memory: 22.7M
        CPU: 89ms
     CGroup: /system.slice/edb-as-17.service
             ├─13289 /usr/edb/as17/bin/edb-postgres -D /var/lib/edb/as17/data
             ├─13290 "postgres: logger "
             ├─13291 "postgres: checkpointer "
             ├─13292 "postgres: background writer "
             ├─13294 "postgres: walwriter "
             ├─13295 "postgres: autovacuum launcher "
             ├─13296 "postgres: dbms_aq launcher "
             └─13297 "postgres: logical replication launcher "

    Mar 16 12:14:08 ol9pgedb systemd[1]: Starting EDB Postgres Advanced Server 17...
    Mar 16 12:14:08 ol9pgedb edb-postgres[13289]: 2025-03-16 12:14:08 -03 LOG:  redirecting log output to logging collector process
    Mar 16 12:14:08 ol9pgedb edb-postgres[13289]: 2025-03-16 12:14:08 -03 HINT:  Future log output will appear in directory "log".
    Mar 16 12:14:08 ol9pgedb systemd[1]: Started EDB Postgres Advanced Server 17.

###### POST INSTALL EDB POSTGRES ( CONFIGURE FIREWALL ) 

    [root@ol9pgedb ~]# firewall-cmd --permanent --zone=trusted --add-source=192.168.18.0/24 
    success
    [root@ol9pgedb ~]# firewall-cmd --permanent --zone=trusted --add-port=5444/tcp
    success
    [root@ol9pgedb ~]# firewall-cmd --reload
    success

###### POST INSTALL EDB POSTGRES ( CONFIGURE INSTANCE ) 

    [root@ol9pgedb ~]# vi /var/lib/edb/as17/data/postgresql.conf
    listen_addresses = '*'
    port = 5444

    [root@ol9pgedb ~]# vi /var/lib/edb/as17/data/pg_hba.conf
    host    all             all             192.168.18.0/24         md5

    [root@ol9pgedb ~]# su - enterprisedb -c "/usr/edb/as17/bin/psql postgres -c 'select pg_reload_conf();'"
     pg_reload_conf 
    ----------------
     t
    (1 row)

    [root@ol9pgedb ~]# systemctl stop edb-as-17
    [root@ol9pgedb ~]# systemctl start edb-as-17

###### POST INSTALL EDB POSTGRES ( RESET PASSWORD EDB POSTGRES ) 

    [root@ol9pgedb ~]# su - enterprisedb 
    [enterprisedb@ol9pgedb ~]$ /usr/edb/as17/bin/psql postgres
    psql (17.4.0)
    Type "help" for help.

    postgres=# \password enterprisedb
    postgres=# \q
    [enterprisedb@ol9pgedb ~]$ exit

###### POST INSTALL EDB POSTGRES ( VALIDATE NETWORK CONNECTION ) 

    [root@ol9pgedb ~]# /usr/edb/edbplus/edbplus.sh enterprisedb/**********@192.168.18.21:5444/edb 
    Connected to EnterpriseDB 17.4.0 (192.168.18.21:5444/edb) AS enterprisedb

    edb*Plus (Build 41.3.0)
    Copyright (c) 2008-2024, EnterpriseDB Corporation.  All rights reserved.

    SQL> exit
    Disconnected from EnterpriseDB Database.


