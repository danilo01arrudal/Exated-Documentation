**ORACLE DATABASE 26ai SINGLE INSTANCE ON OL8.10**


> *Oracle Instant Client is a free software package from Oracle that contains the client libraries needed to connect applications to an Oracle database, either locally or remotely. It is designed to be lightweight and easy to install, eliminating the need for a full Oracle Client installation on client machines.*

![oracle database 26ai logo.](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/oracle_ai_database_26ai_logo.png)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER
    
    virt-install --virt-type kvm --name ol826ai --memory 10240 --vcpus 2 --os-variant ol8.10 --cdrom /var/lib/libvirt/images/OracleLinux-R8-U10-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol826ai.qcow2,size=59

###### CONFIGURE HOSTNAME

    [root@ ~]# hostnamectl set-hostname ol826ai

###### INSTALL PRE-INSTALL PACKAGES

    [root@ol826ai ~]# yum install -y oracle-ai-database-preinstall-26ai.x86_64

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( SET PASSWORD POSTGRES )

	[root@ol826ai ~]# passwd oracle

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( DISABLE FIREWALL )

    [root@ol826ai ~]# systemctl stop firewalld
    [root@ol826ai ~]# systemctl disable firewalld

###### DISABLE SELINUX

    [root@ol826ai ~]# sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config && setenforce 0

###### SETTING CLOCK SOURCE FOR VMs ON LINUX x86-64

    [root@ol826ai ~]# echo "tsc" > /sys/devices/system/clocksource/clocksource0/current_clocksource

###### CONFIGURE STATIC NETWORK
    
    [root@ol826ai ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    lo      loopback  connected (externally)  lo   

    [root@ol826ai ~]# nmcli connection show 
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  82e45657-ca14-380d-adfc-ac71a5aa7281  ethernet  enp1s0 
    lo      c30f3777-2d34-40f9-9fdb-da73383b9848  loopback  lo  

    [root@ol826ai ~]# nmcli con modify 'enp1s0' iframe enp1s0 ipv4.method manual ipv4.addresses 192.168.18.101/24 gw4 192.168.18.1
    [root@ol826ai ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.201
    [root@ol826ai ~]# nmcli con down 'enp1s0'
    [root@ol826ai ~]# nmcli con up 'enp1s0'

    [root@ol826ai ~]# ip addr show enp1s0
    2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:bc:5a:a4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.101/24 brd 192.168.18.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever

    [root@ol826ai ~]# ip route show
    default via 192.168.18.1 dev enp1s0 proto static metric 100 
    192.168.18.0/24 dev enp1s0 proto kernel scope link src 192.168.18.101 metric 100 

###### CREATE ORACLE_BASE AND ORACLE_HOME DIRECTORIES

    [root@ol826ai ~]# mkdir -p /u01/app/oracle/product/23.26.1/dbhome_1/
    [root@ol826ai ~]# chown -R oracle:oinstall /u01
    [root@ol826ai ~]# chmod -R 775 /u01

###### CONFIGURE VARIABLES

    [root@ol826ai ~]# su - oracle
    [oracle@ol826ai ~]$ mkdir /home/oracle/scripts
    [oracle@ol826ai ~]$ cat > /home/oracle/scripts/setEnv.sh <<EOF
    # Oracle Settings
    export TMP=/tmp
    export TMPDIR=\$TMP

    export ORACLE_HOSTNAME=ol826ai
    export ORACLE_UNQNAME=appscdb
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=\$ORACLE_BASE/product/23.26.1/dbhome_1
    export ORA_INVENTORY=/u01/app/oraInventory
    export ORACLE_SID=appscdb

    export PATH=/usr/sbin:/usr/local/bin:\$PATH
    export PATH=\$ORACLE_HOME/bin:\$PATH

    export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
    export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
    EOF

    [oracle@ol826ai ~]$ echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile

    [oracle@ol826ai ~]$ cat > /home/oracle/scripts/start_all.sh <<EOF
	#!/bin/bash
	. /home/oracle/scripts/setEnv.sh

	export ORAENV_ASK=NO
	. oraenv
	export ORAENV_ASK=YES

	dbstart \$ORACLE_HOME
	EOF

    [oracle@ol826ai ~]$ cat > /home/oracle/scripts/stop_all.sh <<EOF
	#!/bin/bash
	. /home/oracle/scripts/setEnv.sh

	export ORAENV_ASK=NO
	. oraenv
	export ORAENV_ASK=YES

	dbshut \$ORACLE_HOME
	EOF

    [oracle@ol826ai ~]$ chown -R oracle:oinstall /home/oracle/scripts
    [oracle@ol826ai ~]$ chmod u+x /home/oracle/scripts/*.sh

###### DOWNLOAD ORACLE DATABASE SOFTWARE
   
    V1054592-01.zip

###### MOVE AND UNZIP DATABASE SOFTWARE
 
    [oracle@ol826ai ~]$ mv V1054592-01.zip /u01/app/oracle/product/23.26.1/dbhome_1/
    [oracle@ol826ai dbhome_1]$ unzip V1054592-01.zip
	[oracle@ol826ai dbhome_1]$ rm -vf V1054592-01.zip 

###### CREATE db_install.rsp INSTALL RESPONSE FILE

    [oracle@ol923ai ~]$ vi db_install.rsp
		oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v23.0.0
		installOption=INSTALL_DB_SWONLY
		UNIX_GROUP_NAME=oinstall
		INVENTORY_LOCATION=/u01/app/oraInventory
		ORACLE_HOME=/u01/app/oracle/product/23.26.1/dbhome_1
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
    [oracle@ol923ai ~]$ cd $ORACLE_HOME
    [oracle@ol923ai ~]$ ./runInstaller -silent -responseFile /home/oracle/db_install.rsp
    [oracle@ol923ai ~]$ exit
    [root@ol923ai ~]# /u01/app/oraInventory/orainstRoot.sh
    [root@ol923ai ~]# /u01/app/oracle/product/23.5.0/dbhome_1/root.sh

###### CREATE dbca.rsp response file

	[oracle@ol923ai ~]$ vi dbca.rsp
		responseFileVersion=/oracle/assistants/rspfmt_dbca_response_schema_v23.0.0
		gdbName=appscdb
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
		pdbName=appspdb1
		useLocalUndoForPDBs=true
		pdbAdminPassword=
		nodelist=
		sehaNodeList=
		templateName=/u01/app/oracle/product/23.26.1/dbhome_1/assistants/dbca/templates/General_Purpose.dbc
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
		olsConfiguration=true
		datafileJarLocation={ORACLE_HOME}/assistants/dbca/templates/
		datafileDestination={ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/
		recoveryAreaDestination={ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}
		recoveryAreaSize=14802MB
		configureWithOID=
		pdbOptions=JSERVER:true,IMEDIA:false,OMS:true,SPATIAL:true,CWMLITE:true,SAMPLE_SCHEMA:false,DV:true,ORACLE_TEXT:true
		dbOptions=JSERVER:true,IMEDIA:false,OMS:true,SPATIAL:true,CWMLITE:true,SAMPLE_SCHEMA:false,DV:true,ORACLE_TEXT:true
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
		variables=ORACLE_BASE_HOME=/u01/app/oracle/product/23.26.1/dbhome_1,DB_UNIQUE_NAME=appscdb,ORACLE_BASE=/u01/app/oracle,PDB_NAME=,DB_NAME=appscdb,ORACLE_HOME=/u01/app/oracle/product/23.26.1/dbhome_1,SID=appscdb
		initParams=undo_tablespace=UNDOTBS1,enable_pluggable_database=true,sga_target=2979MB,db_block_size=8192BYTES,nls_language=AMERICAN,dispatchers=(PROTOCOL=TCP) (SERVICE=appscdbXDB),diagnostic_dest={ORACLE_BASE},control_files=("{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/control01.ctl", "{ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}/control02.ctl"),remote_login_passwordfile=EXCLUSIVE,processes=300,pga_aggregate_target=993MB,nls_territory=AMERICA,local_listener=LISTENER_APPSCDB,db_recovery_file_dest_size=14802MB,open_cursors=300,log_archive_format=%t_%s_%r.dbf,compatible=23.6.0,db_name=appscdb,db_recovery_file_dest={ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}
		enableArchive=true
		useOMF=false
		memoryPercentage=40
		databaseType=MULTIPURPOSE
		automaticMemoryManagement=false
		totalMemory=0

###### CREATE netca.rsp response file

	[oracle@ol923ai ~]$ vi netca.rsp
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

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CONFIGURE HUGEPAGES FOR ORACLE DATABASE INSTANCE ) 

    [root@ol826ai ~]# vi /etc/sysctl.d/99-oracle-ai-database-preinstall-26ai-sysctl.conf 
	# oracle-ai-database-preinstall-26ai for vm.nr_hugepages is 2560
	vm.nr_hugepages = 2560
	# oracle-ai-database-preinstall-26ai setting special parameters END

	[root@ol826ai ~]# sysctl -p /etc/sysctl.d/99-oracle-ai-database-preinstall-26ai-sysctl.conf
	fs.file-max = 6815744
	kernel.sem = 250 32000 100 128
	kernel.shmmni = 4096
	kernel.shmall = 1073741824
	kernel.shmmax = 4398046511104
	kernel.panic_on_oops = 1
	net.core.rmem_default = 262144
	net.core.rmem_max = 4194304
	net.core.wmem_default = 262144
	net.core.wmem_max = 1048576
	net.ipv4.conf.all.rp_filter = 2
	net.ipv4.conf.default.rp_filter = 2
	fs.aio-max-nr = 1048576
	vm.hugetlb_shm_group = 54321
	kernel.panic = 10
	net.ipv4.ip_local_port_range = 9000 65535
	vm.nr_hugepages = 2560
	
	[root@ol826ain1 ~]# grep HugePages_Total /proc/meminfo
	HugePages_Total:    2223

###### CREATE DATABASE 

	[oracle@ol923ai ~]$ dbca -silent -createDatabase -responseFile /home/oracle/dbca.rsp

###### CREATE LISTENER

	[oracle@ol923ai ~]$ netca -silent -responsefile /home/oracle/netca.rsp

###### START LISTENER

	[oracle@ol826ai ~]$ lsnrctl status

	LSNRCTL for Linux: Version 23.26.1.0.0 - Production on 12-FEB-2026 13:57:31

	Copyright (c) 1991, 2026, Oracle.  All rights reserved.

	Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=ol826ai)(PORT=1521)))
	STATUS of the LISTENER
	------------------------
	Alias                     LISTENER
	Version                   TNSLSNR for Linux: Version 23.26.1.0.0 - Production
	Start Date                12-FEB-2026 13:50:10
	Uptime                    0 days 0 hr. 7 min. 21 sec
	Trace Level               off
	Security                  ON: Local OS Authentication
	SNMP                      OFF
	Listener Parameter File   /u01/app/oracle/product/23.26.1/dbhome_1/network/admin/listener.ora
	Listener Log File         /u01/app/oracle/diag/tnslsnr/ol826ai/listener/alert/log.xml
	Listening Endpoints Summary...
	  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=ol826ai.appsdba.info)(PORT=1521)))
	  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
	Services Summary...
	Service "48945b67d121c623e063399b5e6478e6.appsdba.info" has 1 instance(s).
	  Instance "appscdb", status READY, has 1 handler(s) for this service...
	Service "4aa4506a7e84d337e0632c12a8c06620.appsdba.info" has 1 instance(s).
	  Instance "appscdb", status READY, has 1 handler(s) for this service...
	Service "appscdb.appsdba.info" has 1 instance(s).
	  Instance "appscdb", status READY, has 1 handler(s) for this service...
	Service "appscdbXDB.appsdba.info" has 1 instance(s).
	  Instance "appscdb", status READY, has 1 handler(s) for this service...
	Service "appspdb1.appsdba.info" has 1 instance(s).
	  Instance "appscdb", status READY, has 1 handler(s) for this service...
	The command completed successfully

###### ENABLE AUTOMATIC START PDB

	[oracle@ol826ai ~]$ sqlplus / as sysdba

	SQL*Plus: Release 23.26.1.0.0 - Production on Thu Feb 12 13:57:51 2026
	Version 23.26.1.0.0

	Copyright (c) 1982, 2025, Oracle.  All rights reserved.


	Connected to:
	Oracle AI Database 26ai Enterprise Edition Release 23.26.1.0.0 - Production
	Version 23.26.1.0.0

	SQL> show pdbs;                            

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
	---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 APPSPDB1			  READ WRITE NO

	SQL> alter session set container=APPSPDB1;

	Session altered.

 	SQL> ALTER PLUGGABLE DATABASE APPSPDB1 SAVE STATE;

   	Pluggable database altered.
    
	SQL> exit
	Disconnected from Oracle AI Database 26ai Enterprise Edition Release 23.26.1.0.0 - Production
	Version 23.26.1.0.0

###### CONFIGURE TNSNAMES.ORA

	[oracle@ol826ai ~]$ vi /u01/app/oracle/product/23.26.1/dbhome_1/network/admin/tnsnames.ora
	# tnsnames.ora Network Configuration File: /u01/app/oracle/product/23.26.1/dbhome_1/network/admin/tnsnames.ora
	# Generated by Oracle configuration tools.

	APPSCDB =
	  (DESCRIPTION =
	    (ADDRESS = (PROTOCOL = TCP)(HOST = ol826ai)(PORT = 1521))
	    (CONNECT_DATA =
	      (SERVER = DEDICATED)
	      (SERVICE_NAME = appscdb.appsdba.info)
	    )
	  )

	APPSPDB1 =
	  (DESCRIPTION =
	    (ADDRESS_LIST =
	    (ADDRESS = (PROTOCOL = TCP)(HOST = ol826ai)(PORT = 1521)))
	    (CONNECT_DATA =
	      (SERVER = DEDICATED)
	      (SERVICE_NAME = appspdb1.appsdba.info)
	    )
	  )

	LISTENER_APPSCDB =
	  (ADDRESS = (PROTOCOL = TCP)(HOST = ol826ai)(PORT = 1521))

	LISTENER_APPSPDB1 =
	  (ADDRESS = (PROTOCOL = TCP)(HOST = ol826ai)(PORT = 1521))

###### AUTOMATIC START SERVICE ORACLE

	[root@ol826ai ~]# vi /etc/oratab
	# This file is used by ORACLE utilities.  It is created by root.sh
	# and updated by either Database Configuration Assistant while creating
	# a database or ASM Configuration Assistant while creating ASM instance.

	# A colon, ':', is used as the field terminator.  A new line terminates
	# the entry.  Lines beginning with a pound sign, '#', are comments.
	#
	# Entries are of the form:
	#   $ORACLE_SID:$ORACLE_HOME:<N|Y>:
	#
	# The first and second fields are the system identifier and home
	# directory of the database respectively.  The third field indicates
	# to the dbstart utility that the database should , "Y", or should not,
	# "N", be brought up at system boot time.
	#
	# Multiple entries with the same $ORACLE_SID are not allowed.
	#
	#
	appscdb:/u01/app/oracle/product/23.26.1/dbhome_1:Y

###### CONFIGURE ORACLE DATABASE DAEMON 

	[root@ol826ai ~]# vi /lib/systemd/system/dbora.service
	[Unit]
	Description=The Oracle Database Service
	After=syslog.target network.target

	[Service]
	# systemd ignores PAM limits, so set any necessary limits in the service.
	# Not really a bug, but a feature.
	# https://bugzilla.redhat.com/show_bug.cgi?id=754285
	LimitMEMLOCK=134217728
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

	[root@ol826ai ~]# systemctl daemon-reload
	[root@ol826ai ~]# systemctl enable dbora.service

###### writed by: Danilo L. Arruda
