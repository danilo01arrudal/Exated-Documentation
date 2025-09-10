**ORACLE DATABASE 23ai SI FS ONE CDB SILENT MODE OL10.0**


> *Oracle Instant Client is a free software package from Oracle that contains the client libraries needed to connect applications to an Oracle database, either locally or remotely. It is designed to be lightweight and easy to install, eliminating the need for a full Oracle Client installation on client machines.*

![oracle database 23ai logo.](https://github.com/danilo01arrudal/Exated/blob/main/Oracle_Database_23ai/images/1714697079871.png)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER
    
    [root@exated ~]# virt-install --virt-type kvm --name ol1023ai --memory 8192 --vcpus 2 --os-variant ol10.0 --cdrom /var/lib/libvirt/images/OracleLinux-R10-U0-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol1023ai.qcow2,size=50

###### CONFIGURE HOSTNAME

    [root@ ~]# hostnamectl set-hostname ol1023ai

###### INSTALL OPERATING SYSTEM REQUIREMENTS PACKAGES

	[root@ol1023ai ~]# yum install -y binutils
    [root@ol1023ai ~]# yum install -y compat-openssl11
    [root@ol1023ai ~]# yum install -y compat-openssl12
    [root@ol1023ai ~]# yum install -y compat-openssl*
    [root@ol1023ai ~]# yum install -y elfutils-libelf
    [root@ol1023ai ~]# yum install -y fontconfig
    [root@ol1023ai ~]# yum install -y glibc
    [root@ol1023ai ~]# yum install -y glibc-devel
    [root@ol1023ai ~]# yum install -y ksh
    [root@ol1023ai ~]# yum install -y libaio
    [root@ol1023ai ~]# yum install -y libXrender
    [root@ol1023ai ~]# yum install -y libX11
    [root@ol1023ai ~]# yum install -y libXau
    [root@ol1023ai ~]# yum install -y libXi
    [root@ol1023ai ~]# yum install -y libXtst
    [root@ol1023ai ~]# yum install -y libgcc
    [root@ol1023ai ~]# yum install -y libnsl
    [root@ol1023ai ~]# yum install -y libstdc++
    [root@ol1023ai ~]# yum install -y libxcb
    [root@ol1023ai ~]# yum install -y libibverbs
    [root@ol1023ai ~]# yum install -y libasan
    [root@ol1023ai ~]# yum install -y liblsan
    [root@ol1023ai ~]# yum install -y librdmacm
    [root@ol1023ai ~]# yum install -y make
    [root@ol1023ai ~]# yum install -y policycoreutils
    [root@ol1023ai ~]# yum install -y policycoreutils-python-utils
    [root@ol1023ai ~]# yum install -y smartmontools
    [root@ol1023ai ~]# yum install -y sysstat
    [root@ol1023ai ~]# yum install -y ipmiutil
    [root@ol1023ai ~]# yum install -y libaio
    [root@ol1023ai ~]# yum install -y nfs-utils
    [root@ol1023ai ~]# yum install -y perl-core

###### COMPILE OPENSSL 3.5.2 (PACKAGE COMPAT-OPENSSL11 IS NOT SUPPORTED ON ORACLE LINUX 10)

    [root@ol1023ai ~]# wget https://github.com/openssl/openssl/releases/download/openssl-3.5.2/openssl-3.5.2.tar.gz
    [root@ol1023ai ~]# tar -xvzf openssl-3.5.2.tar.gz
    [root@ol1023ai ~]# cd openssl-3.5.2/
    [root@ol1023ai ~]# ./config
    [root@ol1023ai ~]# make install
    [root@ol1023ai ~]# ldconfig /usr/local/lib64/
    [root@ol1023ai ~]# openssl version -v

###### ADD SYSCTL PARAMETERS IN /etc/sysctl.conf FILE 

    [root@ol1023ai ~]# vi /etc/sysctl.conf
    	# oracle-database-preinstall-23ai setting for fs.file-max is 6815744
    	fs.file-max = 6815744

    	# oracle-database-preinstall-23ai setting for kernel.sem is '250 32000 100 128'
    	kernel.sem = 250 32000 100 128

    	# oracle-database-preinstall-23ai setting for kernel.shmmni is 4096
    	kernel.shmmni = 4096

    	# oracle-database-preinstall-23ai setting for kernel.shmall is 1073741824 on x86_64
    	kernel.shmall = 1073741824

    	# oracle-database-preinstall-23ai setting for kernel.shmmax is 4398046511104 on x86_64
    	kernel.shmmax = 4398046511104

    	# oracle-database-preinstall-23ai setting for kernel.panic_on_oops is 1 per Orabug 19212317
    	kernel.panic_on_oops = 1

    	# oracle-database-preinstall-23ai setting for net.core.rmem_default is 262144
    	net.core.rmem_default = 262144

		# oracle-database-preinstall-23ai setting for net.core.rmem_max is 4194304
		net.core.rmem_max = 4194304

		# oracle-database-preinstall-23ai setting for net.core.wmem_default is 262144
		net.core.wmem_default = 262144

		# oracle-database-preinstall-23ai setting for net.core.wmem_max is 1048576
		net.core.wmem_max = 1048576

		# oracle-database-preinstall-23ai setting for net.ipv4.conf.all.rp_filter is 2
		net.ipv4.conf.all.rp_filter = 2

		# oracle-database-preinstall-23ai setting for net.ipv4.conf.default.rp_filter is 2
		net.ipv4.conf.default.rp_filter = 2

		# oracle-database-preinstall-23ai setting for fs.aio-max-nr is 1048576
		fs.aio-max-nr = 1048576

		# oracle-database-preinstall-23ai setting for net.ipv4.ip_local_port_range is 9000 65500
		net.ipv4.ip_local_port_range = 9000 65535

		# oracle-database-preinstall-23ai setting special parameters BEGIN
		# oracle-database-preinstall-23ai setting for kernel.panic is 10
		kernel.panic = 10

		# oracle-database-preinstall-23ai setting special parameters END

###### RELOAD SYSCTL PARAMETERS

	[root@ol1023ai ~]# /sbin/sysctl -p  

###### UPDATE SYSTEM LIMITS 

	[root@ol1023ai ~]# vi /etc/security/limits.d/oracle-database-preinstall-23ai.conf
 		# oracle-database-preinstall-23ai setting for nofile soft limit is 1024
		oracle   soft   nofile    1024

		# oracle-database-preinstall-23ai setting for nofile hard limit is 65536
		oracle   hard   nofile    65536

		# oracle-database-preinstall-23ai setting for nproc soft limit is 16384
		# refer orabug15971421 for more info.
		oracle   soft   nproc    16384

		# oracle-database-preinstall-23ai setting for nproc hard limit is 16384
		oracle   hard   nproc    16384

		# oracle-database-preinstall-23ai setting for stack soft limit is 10240KB
		oracle   soft   stack    10240

		# oracle-database-preinstall-23ai setting for stack hard limit is 32768KB
		oracle   hard   stack    32768

		# oracle-database-preinstall-23ai setting for memlock hard limit is maximum of 128GB on x86_64 or 3GB on x86 OR 90 % of RAM
		oracle   hard   memlock    134217728

		# oracle-database-preinstall-23ai setting for memlock soft limit is maximum of 128GB on x86_64 or 3GB on x86 OR 90% of RAM
		oracle   soft   memlock    134217728

		# oracle-database-preinstall-23ai setting for data soft limit is 'unlimited'
		oracle   soft   data    unlimited

		# oracle-database-preinstall-23ai setting for data hard limit is 'unlimited'
		oracle   hard   data    unlimited

###### CREATE USER AND GRUPS FOR ORACLE DATABASE

    [root@ol1023ai ~]# userdel oracle; rm -Rvf /home/oracle; rm -Rvf /var/mail/oracle; groupadd -g 54321 oinstall; groupadd -g 54322 dba; groupadd -g 54323 oper; groupadd -g 54324 backupdba; groupadd -g 54325 dgdba; groupadd -g 54326 kmdba; groupadd -g 54327 asmdba; groupadd -g 54328 asmoper; groupadd -g 54329 asmadmin; groupadd -g 54330 racdba; useradd -m -u 54331 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,asmdba,asmadmin,racdba -d /home/oracle -s /bin/bash  oracle; useradd -m -u 54332 -g oinstall -G dba,asmadmin,asmdba,asmoper -d /home/grid -s /bin/bash  grid; id oracle; id grid
	[root@ol1023ai ~]# passwd oracle

###### DISABLE SELINUX

    [root@ol1023ai ~]# sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config && setenforce 0

###### SETTING CLOCK SOURCE FOR VMs ON LINUX x86-64

    [root@ol1023ai ~]# echo "tsc" > /sys/devices/system/clocksource/clocksource0/current_clocksource

###### CONFIGURE STATIC NETWORK
    
    [root@ol1023ai ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    lo      loopback  connected (externally)  lo   

    [root@ol1023ai ~]# nmcli connection show 
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  82e45657-ca14-380d-adfc-ac71a5aa7281  ethernet  enp1s0 
    lo      c30f3777-2d34-40f9-9fdb-da73383b9848  loopback  lo  

    [root@ol1023ai ~]# nmcli con modify 'enp1s0' iframe enp1s0 ipv4.method manual ipv4.addresses 192.168.18.101/24 gw4 192.168.18.1
    [root@ol1023ai ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.201
    [root@ol1023ai ~]# nmcli con down 'enp1s0'
    [root@ol1023ai ~]# nmcli con up 'enp1s0'

    [root@ol1023ai ~]# ip addr show enp1s0
    2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:bc:5a:a4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.101/24 brd 192.168.18.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever

    [root@ol1023ai ~]# ip route show
    default via 192.168.18.1 dev enp1s0 proto static metric 100 
    192.168.18.0/24 dev enp1s0 proto kernel scope link src 192.168.18.101 metric 100 

###### CREATE ORACLE_BASE AND ORACLE_HOME DIRECTORIES

    [root@ol1023ai ~]# mkdir -p /u01/app/oracle/product/23.7.0/dbhome_1/
    [root@ol1023ai ~]# chown -R oracle:oinstall /u01
    [root@ol1023ai ~]# chmod -R 775 /u01

###### CONFIGURE VARIABLES

    [root@ol1023ai ~]# su - oracle
    [oracle@ol1023ai ~]$ mkdir /home/oracle/scripts
    [oracle@ol1023ai ~]$ cat > /home/oracle/scripts/setEnv.sh <<EOF
    # Oracle Settings
    export TMP=/tmp
    export TMPDIR=\$TMP

    export ORACLE_HOSTNAME=ol1023ai
    export ORACLE_UNQNAME=appscdb
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=\$ORACLE_BASE/product/23.7.0/dbhome_1
    export ORA_INVENTORY=/u01/app/oraInventory
    export ORACLE_SID=appscdb1

    export PATH=/usr/sbin:/usr/local/bin:\$PATH
    export PATH=\$ORACLE_HOME/bin:\$PATH

    export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
    export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
    EOF

    [oracle@ol1023ai ~]$ echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile

    [oracle@ol1023ai ~]$ cat > /home/oracle/scripts/start_all.sh <<EOF
	#!/bin/bash
	. /home/oracle/scripts/setEnv.sh

	export ORAENV_ASK=NO
	. oraenv
	export ORAENV_ASK=YES

	dbstart \$ORACLE_HOME
	EOF

    [oracle@ol1023ai ~]$ cat > /home/oracle/scripts/stop_all.sh <<EOF
	#!/bin/bash
	. /home/oracle/scripts/setEnv.sh

	export ORAENV_ASK=NO
	. oraenv
	export ORAENV_ASK=YES

	dbshut \$ORACLE_HOME
	EOF

    [oracle@ol1023ai ~]$ chown -R oracle:oinstall /home/oracle/scripts
    [oracle@ol1023ai ~]$ chmod u+x /home/oracle/scripts/*.sh

###### DOWNLOAD ORACLE DATABASE SOFTWARE
   
    V1043785-01.zip

###### MOVE AND UNZIP DATABASE SOFTWARE
 
    [oracle@ol1023ai ~]$ mv V1043785-01.zip /u01/app/oracle/product/23.5.0/dbhome_1/
    [oracle@ol1023ai dbhome_1]$ gunzip V1043785-01.zip 

###### CREATE db_install.rsp INSTALL RESPONSE FILE

    [oracle@ol1023ai ~]$ vi db_install.rsp
		oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v23.0.0
		installOption=INSTALL_DB_SWONLY
		UNIX_GROUP_NAME=oinstall
		INVENTORY_LOCATION=/u01/app/oraInventory
		ORACLE_HOME=/u01/app/oracle/product/23.7.0/dbhome_1
		ORACLE_BASE=/u01/app/oracle
		installEdition=EE
		OSDBA=dba
		OSOPER=oinstall
		OSBACKUPDBA=backupdba
		OSDGDBA=dgdba
		OSKMDBA=kmdba
		OSRACDBA=racdba
		executeRootScript=false
		configMethod=
		sudoPath=
		sudoUserName=
		clusterNodes=
		dbType=GENERAL_PURPOSE
		gdbName=
		dbSID=
		pdbName=
		charSet=
		enableAutoMemoryManagement=
		memoryLimit=
		allSchemaPassword=
		sysPassword=
		systemPassword=
		dbsnmpPassword=
		pdbadminPassword=
		managementOption=DEFAULT
		omsHost=
		omsPort=
		emAdminUser=
		emAdminPassword=
		enableRecovery=
		storageType=
		dataLocation=
		recoveryLocation=
		diskGroup=
		asmsnmpPassword=

###### EXECUTE runInstaller 
    [oracle@ol1023ai ~]$ cd $ORACLE_HOME
    [oracle@ol1023ai ~]$ ./runInstaller -silent -responseFile /home/oracle/db_install.rsp
    [oracle@ol1023ai ~]$ exit
    [root@ol1023ai ~]# /u01/app/oraInventory/orainstRoot.sh
    [root@ol1023ai ~]# /u01/app/oracle/product/23.5.0/dbhome_1/root.sh

###### CREATE dbca.rsp response file

	[oracle@ol1023ai ~]$ vi dbca.rsp
		responseFileVersion=/oracle/assistants/rspfmt_dbca_response_schema_v23.0.0
		gdbName=appscdb.appsdba.info
		sid=appscdb
		databaseConfigType=SI
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
		pdbName=appspdb
		useLocalUndoForPDBs=true
		pdbAdminPassword=
		nodelist=
		sehaNodeList=
		templateName=/u01/app/oracle/product/23.7.0/dbhome_1/assistants/dbca/templates/General_Purpose.dbc
		sysPassword=
		systemPassword=
		serviceUserPassword=	
		emConfiguration=
		runCVUChecks=FALSE
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
		datafileDestination={ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/
		recoveryAreaDestination=
		recoveryAreaSize=54525952BYTES
		configureWithOID=
		pdbOptions=IMEDIA:false,OMS:true,ORACLE_TEXT:true,DV:true,JSERVER:true,SAMPLE_SCHEMA:false,CWMLITE:true,SPATIAL:true
		dbOptions=IMEDIA:false,OMS:true,ORACLE_TEXT:true,DV:true,JSERVER:true,SAMPLE_SCHEMA:false,CWMLITE:true,SPATIAL:true
		storageType=FS
		diskGroupName=
		asmsnmpPassword=
		recoveryGroupName=
		characterSet=AL32UTF8
		nationalCharacterSet=AL16UTF16
		registerWithDirService=false
		dirServiceUserName=
		dirServicePassword=
		walletPassword=
		listeners=
		skipListenerRegistration=true
		variablesFile=
		variables=ORACLE_BASE_HOME=/u01/app/oracle/product/23.7.0/dbhome_1,DB_UNIQUE_NAME=appscdb,ORACLE_BASE=/u01/app/oracle,PDB_NAME=,DB_NAME=appscdb,ORACLE_HOME=/u01/app/oracle/product/23.7.0/dbhome_1,SID=appscdb
		initParams=undo_tablespace=UNDOTBS1,enable_pluggable_database=true,sga_target=2379MB,db_block_size=8192BYTES,nls_language=AMERICAN,dispatchers=(PROTOCOL=TCP)(SERVICE=appscdbXDB),diagnostic_dest={ORACLE_BASE},control_files=("{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/control01.ctl","{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/control02.ctl"),remote_login_passwordfile=EXCLUSIVE,_exadata_feature_on=true,processes=300,pga_aggregate_target=793MB,nls_territory=AMERICA,open_cursors=300,db_domain=appsdba.info,compatible=23.6.0,db_name=appscdb
		enableArchive=false
		useOMF=false
		memoryPercentage=40
		databaseType=MULTIPURPOSE
		automaticMemoryManagement=false
		totalMemory=0

###### CREATE netca.rsp response file

	[oracle@ol1023ai ~]$ vi netca.rsp
				[GENERAL]
				RESPONSEFILE_VERSION="23.0"
				CREATE_TYPE="CUSTOM"
				INSTALLED_COMPONENTS={"server","net8","javavm"}
				INSTALL_TYPE=""typical""
				LISTENER_NUMBER=1
				LISTENER_NAMES={"LISTENER"}
				LISTENER_START=""LISTENER""
				NAMING_METHODS={"TNSNAMES","ONAMES","HOSTNAME"}
				NSN_NUMBER=1
				NSN_NAMES={"EXTPROC_CONNECTION_DATA"}
				NSN_SERVICE={"PLSExtProc"}
    			NSN_SERVICE={"PLSExtProc"}
				NSN_PROTOCOLS={"TCP;HOSTNAME;1521"}

###### CREATE DATABASE 

	[oracle@ol1023ai ~]$ dbca -silent -createDatabase -responseFile /home/oracle/dbca.rsp

###### CREATE LISTENER

	[oracle@ol1023ai ~]$ netca -silent -responsefile /home/oracle/netca.rsp

###### START LISTENER

	[oracle@ol1023ai ~]$ lsnrctl status

		LSNRCTL for Linux: Version 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on 08-SEP-2025 23:01:35

		Copyright (c) 1991, 2024, Oracle.  All rights reserved.

		Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
		STATUS of the LISTENER
		------------------------
		Alias                     LISTENER
		Version                   TNSLSNR for Linux: Version 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
		Start Date                08-SEP-2025 20:01:07
		Uptime                    0 days 3 hr. 0 min. 29 sec
		Trace Level               off
		Security                  ON: Local OS Authentication
		SNMP                      OFF
		Listener Log File         /u01/app/oracle/diag/tnslsnr/localhost/listener/alert/log.xml
		Listening Endpoints Summary...
		  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1521)))
		Services Summary...
		Service "2bd45b2c420628bbe06337d35e643db0.appsdba.info" has 1 instance(s).
		  Instance "appscdb", status READY, has 1 handler(s) for this service...
		Service "3e3f134b5c828a1ae063d812a8c0a662.appsdba.info" has 1 instance(s).
		  Instance "appscdb", status READY, has 1 handler(s) for this service...
		Service "appscdb.appsdba.info" has 1 instance(s).
		  Instance "appscdb", status READY, has 1 handler(s) for this service...
		Service "appscdbXDB.appsdba.info" has 1 instance(s).
		  Instance "appscdb", status READY, has 1 handler(s) for this service...
		Service "appspdb.appsdba.info" has 1 instance(s).
		  Instance "appscdb", status READY, has 1 handler(s) for this service...
		The command completed successfully

###### ENABLE AUTOMATIC START PDB

	[oracle@ol1023ai ~]$ sqlplus / as sysdba

		SQL*Plus: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Mon Sep 8 23:03:24 2025
		Version 23.7.0.25.01

		Copyright (c) 1982, 2024, Oracle.  All rights reserved.

		Connected to:
		Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
		Version 23.7.0.25.01

	SQL> ALTER PLUGGABLE DATABASE APPSPDB OPEN;

	Pluggable database altered.

	SQL> @state
	SQL> col col_name for a30
	SQL> select con_name, state from dba_pdb_saved_states
	  2 / 

	no rows selected

 	SQL> ALTER PLUGGABLE DATABASE APPSPDB SAVE STATE;

   	Pluggable database altered.

	SQL> @state
	SQL> col col_name for a30
	SQL> select con_name, state from dba_pdb_saved_states
	  2 / 

	CON_NAME			STATE
	------------------------------- -------------
	APPSPDB
    
	SQL> exit
	Disconnected from Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Version 23.7.0.25.01

###### CONFIGURE TNSNAMES.ORA

	[oracle@ol1023ai ~]$ cat > /u01/app/oracle/product/23.5.0/dbhome_1/network/admin/tnsnames.ora <<EOF
				appspdb =
				  (DESCRIPTION =
				    (ADDRESS_LIST =
				      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.18.101)(PORT = 1521))
				    )
				    (CONNECT_DATA =
				      (SERVICE_NAME = appspdb)
				    )
				  )

				appscdb =
				  (DESCRIPTION =
				    (ADDRESS_LIST =
				      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.18.101)(PORT = 1521))
				    )
				    (CONNECT_DATA =
				      (SERVICE_NAME = appscdb)
				    )
				  )
				EOF  

###### AUTOMATIC START SERVICE ORACLE

	[root@ol1023ai ~]# vi /etc/oratab
 				appscdb1:/u01/app/oracle/product/23.7.0/dbhome_1:Y

###### CONFIGURE ORACLE DATABASE DAEMON 

	[root@ol1023ai ~]# vi /lib/systemd/system/dbora.service
				[Unit]
				Description=The Oracle Database Service
				After=syslog.target network.target

				[Service]
				# systemd ignores PAM limits, so set any necessary limits in the service.
				# Not really a bug, but a feature.
				# https://bugzilla.redhat.com/show_bug.cgi?id=754285
				LimitMEMLOCK=infinity
				LimitNOFILE=65535

				#Type=simple
				# idle: similar to simple, the actual execution of the service binary is delayed
				#       until all jobs are finished, which avoids mixing the status output with shell output of services.
				RemainAfterExit=yes
				User=oracle
				Group=oinstall
				Restart=no
				ExecStart=/bin/bash -c '/home/oracle/scripts/start_all.sh'
				ExecStop=/bin/bash -c '/home/oracle/scripts/stop_all.sh'

				[Install]
				WantedBy=multi-user.target

	[root@ol1023ai ~]# systemctl daemon-reload
	[root@ol1023ai ~]# systemctl enable dbora.service

###### writed by: Danilo Arruda
###### seg 8 set 2025
