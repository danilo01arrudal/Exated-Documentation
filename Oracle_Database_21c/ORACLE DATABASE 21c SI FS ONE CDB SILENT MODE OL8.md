**ORACLE DATABASE 19c SI FS ONE CDB SILENT MODE OL9.5**


> *Oracle Database 19c has features such as advanced partitioning, multitenancy support, data compression, and automation tools such as the Autonomous Health Framework, 19c is ideal for mission-critical environments. In addition, it includes improvements in machine learning, integration with big data, and support for hybrid architectures, being widely used in on-premises and cloud databases.*

![oracle database 19c logo.](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Database_21c/images/oracle_database_21c_logo.png)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER
    
    [root@exated ~]# virt-install --virt-type kvm --name ol9d --memory 4096 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9d.qcow2,size=50

###### CONFIGURE HOSTNAME

    [root@ ~]# hostnamectl set-hostname ol821c

###### INSTALL PRE-INSTALL PACKAGES

    [root@ol821c ~]# yum install oracle-database-preinstall-21c

###### DISABLE SELINUX

    [root@ol821c ~]# sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config && setenforce 0

###### CONFIGURE STATIC NETWORK
    
    [root@ol821c ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    lo      loopback  connected (externally)  lo   

    [root@ol821c ~]# nmcli connection show 
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  82e45657-ca14-380d-adfc-ac71a5aa7281  ethernet  enp1s0 
    lo      c30f3777-2d34-40f9-9fdb-da73383b9848  loopback  lo  

    [root@ol821c ~]# nmcli con modify 'enp1s0' iframe enp1s0 ipv4.method manual ipv4.addresses 192.168.18.211/24 gw4 192.168.18.1
    [root@ol821c ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.201
    [root@ol821c ~]# nmcli con down 'enp1s0'
    [root@ol821c ~]# nmcli con up 'enp1s0'

    [root@ol821c ~]# ip addr show enp1s0
    2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:bc:5a:a4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.101/24 brd 192.168.18.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever

    [root@ol821c ~]# ip route show
    default via 192.168.18.1 dev enp1s0 proto static metric 100 
    192.168.18.0/24 dev enp1s0 proto kernel scope link src 192.168.18.101 metric 100 

###### CREATE ORACLE_BASE AND ORACLE_HOME DIRECTORIES

    [root@ol821c ~]# mkdir -p /u01/app/oracle/product/23.5.0/dbhome_1/
    [root@ol821c ~]# chown -R oracle:oinstall /u01
    [root@ol821c ~]# chmod -R 775 /u01

###### CONFIGURE VARIABLES

    [root@ol821c ~]# su - oracle
    [oracle@ol821c ~]$ mkdir /home/oracle/scripts
    [oracle@ol821c ~]$ cat > /home/oracle/scripts/setEnv.sh <<EOF
    # Oracle Settings
    export TMP=/tmp
    export TMPDIR=\$TMP

    export ORACLE_HOSTNAME=ol821c
    export ORACLE_UNQNAME=appscdb
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=\$ORACLE_BASE/product/21.3.0/dbhome_1
    export ORA_INVENTORY=/u01/app/oraInventory
    export ORACLE_SID=appscdb1

    export PATH=/usr/sbin:/usr/local/bin:\$PATH
    export PATH=\$ORACLE_HOME/bin:\$PATH

    export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
    export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
    EOF

    [oracle@ol821c ~]$ echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile

    [oracle@ol821c ~]$ cat > /home/oracle/scripts/start_all.sh <<EOF
	#!/bin/bash
	. /home/oracle/scripts/setEnv.sh

	export ORAENV_ASK=NO
	. oraenv
	export ORAENV_ASK=YES

	dbstart \$ORACLE_HOME
    EOF

    [oracle@ol821c ~]$ cat > /home/oracle/scripts/stop_all.sh <<EOF
	#!/bin/bash
	. /home/oracle/scripts/setEnv.sh

	export ORAENV_ASK=NO
	. oraenv
	export ORAENV_ASK=YES

	dbshut \$ORACLE_HOME
	EOF

    [oracle@ol821c ~]$ chown -R oracle:oinstall /home/oracle/scripts
    [oracle@ol821c ~]$ chmod u+x /home/oracle/scripts/*.sh

###### DOWNLOAD ORACLE DATABASE SOFTWARE
   
    LINUX.X64_193000_db_home.zip

###### MOVE AND UNZIP DATABASE SOFTWARE
 
    [oracle@ol821c ~]$ mv LINUX.X64_193000_db_home.zip /u01/app/oracle/product/19.3.0/dbhome_1/
    [oracle@ol821c dbhome_1]$ gunzip LINUX.X64_193000_db_home.zip

###### CREATE db_install.rsp INSTALL RESPONSE FILE

    [oracle@ol821c ~]$ vi db_install.rsp
	oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v19.0.0
	oracle.install.option=INSTALL_DB_SWONLY
	UNIX_GROUP_NAME=oinstall
	INVENTORY_LOCATION=/u01/app/oraInventory
	ORACLE_BASE=/u01/app/oracle
	oracle.install.db.InstallEdition=EE
	oracle.install.db.OSDBA_GROUP=dba
	oracle.install.db.OSOPER_GROUP=oinstall
	oracle.install.db.OSBACKUPDBA_GROUP=backupdba
	oracle.install.db.OSDGDBA_GROUP=dgdba
	oracle.install.db.OSKMDBA_GROUP=kmdba
	oracle.install.db.OSRACDBA_GROUP=racdba
	oracle.install.db.rootconfig.executeRootScript=false
	oracle.install.db.rootconfig.configMethod=
	oracle.install.db.rootconfig.sudoPath=
	oracle.install.db.rootconfig.sudoUserName=
	oracle.install.db.CLUSTER_NODES=
	oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
	oracle.install.db.config.starterdb.globalDBName=
	oracle.install.db.config.starterdb.SID=
	oracle.install.db.ConfigureAsContainerDB=false
	oracle.install.db.config.PDBName=
	oracle.install.db.config.starterdb.characterSet=
	oracle.install.db.config.starterdb.memoryOption=false
	oracle.install.db.config.starterdb.memoryLimit=
	oracle.install.db.config.starterdb.installExampleSchemas=false
	oracle.install.db.config.starterdb.password.ALL=
	oracle.install.db.config.starterdb.password.SYS=
	oracle.install.db.config.starterdb.password.SYSTEM=
	oracle.install.db.config.starterdb.password.DBSNMP=
	oracle.install.db.config.starterdb.password.PDBADMIN=
	oracle.install.db.config.starterdb.managementOption=DEFAULT
	oracle.install.db.config.starterdb.omsHost=
	oracle.install.db.config.starterdb.omsPort=0
	oracle.install.db.config.starterdb.emAdminUser=
	oracle.install.db.config.starterdb.emAdminPassword=
	oracle.install.db.config.starterdb.enableRecovery=false
	oracle.install.db.config.starterdb.storageType=
	oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=
	oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
	oracle.install.db.config.asm.diskGroup=
	oracle.install.db.config.asm.ASMSNMPPassword=

###### EXECUTE runInstaller 
    [oracle@ol821c ~]$ cd $ORACLE_HOME
    [oracle@ol821c ~]$ ./runInstaller -silent -responseFile /home/oracle/db_install.rsp
    [oracle@ol821c ~]$ exit
    [root@ol821c ~]# /u01/app/oraInventory/orainstRoot.sh
    [root@ol821c ~]# /u01/app/oracle/product/23.5.0/dbhome_1/root.sh

###### CREATE dbca.rsp response file

    [oracle@ol821c ~]$ vi dbca.rsp
	responseFileVersion=/oracle/assistants/rspfmt_dbca_response_schema_v21.0.0
	gdbName=appscdb
	sid=appscdb1
	databaseConfigType=SI
	RACOneNodeServiceName=
	policyManaged=false
	managementPolicy=
	createServerPool=false
	serverPoolName=
	cardinality=
	force=
	pqPoolName=
	pqCardinality=
	createAsContainerDatabase=true
	numberOfPDBs=1
	pdbName=appspdb
	useLocalUndoForPDBs=true
	pdbAdminPassword=
	nodelist=
	templateName=/u01/app/oracle/product/21.3.0/dbhome_1/assistants/dbca/templates/General_Purpose.dbc
	sysPassword=
	systemPassword= 
	oracleHomeUserPassword=
	emConfiguration=
	runCVUChecks=FALSE
	dbsnmpPassword=
	omsHost=
	omsPort=
	emUser=
	emPassword=
	dvConfiguration=false
	dvUserName=
	dvUserPassword=
	dvAccountManagerName=
	dvAccountManagerPassword=
	olsConfiguration=
	datafileJarLocation={ORACLE_HOME}/assistants/dbca/templates/
	datafileDestination={ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/
	recoveryAreaDestination={ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}
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
	variablesFile=
	variables=ORACLE_BASE_HOME=/u01/app/oracle/product/21.3.0/dbhome_1,DB_UNIQUE_NAME=appscdb,ORACLE_BASE=/u01/app/oracle,PDB_NAME=,DB_NAME=appscdb,ORACLE_HOME=/u01/app/oracle/product/21.3.0/dbhome_1,SID=appscdb1
	initParams=_exadata_feature_on=true,undo_tablespace=UNDOTBS1,sga_target=2047MB,db_block_size=8192BYTES,log_archive_dest_1='LOCATION={ORACLE_BASE}/oradata/archivelog/',nls_language=AMERICAN,dispatchers=(PROTOCOL=TCP) (SERVICE=appscdb1XDB),diagnostic_dest={ORACLE_BASE},control_files=("{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/control01.ctl", "{ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}/control02.ctl"),remote_login_passwordfile=EXCLUSIVE,audit_file_dest={ORACLE_BASE}/admin/{DB_UNIQUE_NAME}/adump,processes=600,pga_aggregate_target=683MB,nls_territory=AMERICA,db_recovery_file_dest_size=12732MB,open_cursors=300,log_archive_format=%t_%s_%r.dbf,compatible=21.0.0,db_name=appscdb,db_recovery_file_dest={ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME},audit_trail=db
	sampleSchema=false
	memoryPercentage=40
	databaseType=MULTIPURPOSE
	automaticMemoryManagement=false
	totalMemory=0

###### CREATE netca.rsp response file

	[oracle@ol821c ~]$ vi netca.rsp
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

	[oracle@ol821c ~]$ dbca -silent -createDatabase -responseFile /home/oracle/dbca.rsp

###### CREATE LISTENER

	[oracle@ol821c ~]$ netca -silent -responsefile /home/oracle/netca.rsp

###### START LISTENER

	[oracle@ol821c ~]$ lsnrctl status

	LSNRCTL for Linux: Version 21.0.0.0.0 - Production on 19-MAY-2025 13:39:42

	Copyright (c) 1991, 2021, Oracle.  All rights reserved.

	Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
	STATUS of the LISTENER
	------------------------
	Alias                     LISTENER
	Version                   TNSLSNR for Linux: Version 21.0.0.0.0 - Production
	Start Date                19-MAY-2025 13:39:36
	Uptime                    0 days 0 hr. 0 min. 6 sec
	Trace Level               off
	Security                  ON: Local OS Authentication
	SNMP                      OFF
	Listener Log File         /u01/app/oracle/diag/tnslsnr/ol821c/listener/alert/log.xml
	Listening Endpoints Summary...
	  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=ol821c.appsdba.info)(PORT=1521)))
	The listener supports no services
	The command completed successfully

###### ENABLE AUTOMATIC START PDB

	[oracle@ol821c ~]$ sqlplus / as sysdba 

	SQL*Plus: Release 21.0.0.0.0 - Production on Mon May 19 13:42:11 2025
	Version 21.3.0.0.0

	Copyright (c) 1982, 2021, Oracle.  All rights reserved.


	Connected to:
	Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
	Version 21.3.0.0.0

	SQL> show pdbs;

	    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
	---------- ------------------------------ ---------- ----------
		 2 PDB$SEED			  READ ONLY  NO
		 3 APPSPDB			  READ WRITE NO
	SQL> alter session set container=APPSPDB;

	Session altered.

	SQL> ALTER PLUGGABLE DATABASE APPSPDB SAVE STATE;

	Pluggable database altered.

	SQL> exit
	Disconnected from Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
	Version 21.3.0.0.0

###### CONFIGURE TNSNAMES.ORA

	[oracle@ol821c ~]$ cat > /u01/app/oracle/product/21.3.0/dbhome_1/network/admin/tnsnames.ora <<EOF
	appspdb =
	  (DESCRIPTION =
	    (ADDRESS_LIST =
	      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.18.212)(PORT = 1521))
	    )
	    (CONNECT_DATA =
 	     (SERVICE_NAME = appspdb)
	    )
	  )

	appscdb =
	  (DESCRIPTION =
	    (ADDRESS_LIST =
	      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.18.212)(PORT = 1521))
	    )
	    (CONNECT_DATA =
	      (SERVICE_NAME = appscdb)
	    )
	  )
	EOF  

###### AUTOMATIC START SERVICE ORACLE

	[root@ol821c ~]# vi /etc/oratab
 				appscdb1:/u01/app/oracle/product/23.5.0/dbhome_1:Y

###### CONFIGURE ORACLE DATABASE DAEMON 

	[root@ol821c ~]# vi /lib/systemd/system/dbora.service
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

	[root@ol821c ~]# systemctl daemon-reload
	[root@ol821c ~]# systemctl enable dbora.service

###### writed by: Danilo Arruda
###### ter 18 fev 2025
