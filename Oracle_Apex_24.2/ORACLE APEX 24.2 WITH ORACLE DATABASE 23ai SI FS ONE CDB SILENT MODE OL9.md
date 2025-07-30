**ORACLE APEX 24.2 WITH ORACLE DATABASE 23ai SI FS ONE CDB SILENT MODE OL9.5**


> *Oracle Instant Client is a free software package from Oracle that contains the client libraries needed to connect applications to an Oracle database, either locally or remotely. It is designed to be lightweight and easy to install, eliminating the need for a full Oracle Client installation on client machines.*

![oracle_apex_24_logo.](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Apex_24.2/images/images.png)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER
    
    [root@exated ~]# virt-install --virt-type kvm --name ol9d --memory 4096 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9d.qcow2,size=50

###### CONFIGURE HOSTNAME

    [root@ ~]# hostnamectl set-hostname ol9apex24

###### INSTALL PRE-INSTALL PACKAGES

    [root@ol9apex24 ~]# dnf install -y oracle-database-preinstall-23ai
    [root@ol9apex24 ~]# dnf install -y https://download.oracle.com/java/24/latest/jdk-24_linux-x64_bin.rpm

###### DISABLE SELINUX

    [root@ol9apex24 ~]# sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config && setenforce 0

###### OPEN PORT ON FIREWALLD

    [root@ol9apex24 ~]# firewall-cmd --zone=public --add-port=8080/tcp --permanent
    [root@ol9apex24 ~]# firewall-cmd --reload

###### SETTING CLOCK SOURCE FOR VMs ON LINUX x86-64

    [root@ol9apex24 ~]# echo "tsc" > /sys/devices/system/clocksource/clocksource0/current_clocksource

###### CONFIGURE STATIC NETWORK
    
    [root@ol9apex24 ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    lo      loopback  connected (externally)  lo   

    [root@ol9apex24 ~]# nmcli connection show 
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  82e45657-ca14-380d-adfc-ac71a5aa7281  ethernet  enp1s0 
    lo      c30f3777-2d34-40f9-9fdb-da73383b9848  loopback  lo  

    [root@ol9apex24 ~]# nmcli con modify 'enp1s0' iframe enp1s0 ipv4.method manual ipv4.addresses 192.168.18.101/24 gw4 192.168.18.1
    [root@ol9apex24 ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.201
    [root@ol9apex24 ~]# nmcli con down 'enp1s0'
    [root@ol9apex24 ~]# nmcli con up 'enp1s0'

    [root@ol9apex24 ~]# ip addr show enp1s0
    2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:bc:5a:a4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.101/24 brd 192.168.18.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever

    [root@ol9apex24 ~]# ip route show
    default via 192.168.18.1 dev enp1s0 proto static metric 100 
    192.168.18.0/24 dev enp1s0 proto kernel scope link src 192.168.18.101 metric 100 

###### CREATE ORACLE_BASE AND ORACLE_HOME DIRECTORIES

    [root@ol9apex24 ~]# mkdir -p /u01/app/oracle/product/23.5.0/dbhome_1/
    [root@ol9apex24 ~]# chown -R oracle:oinstall /u01
    [root@ol9apex24 ~]# chmod -R 775 /u01

###### CONFIGURE VARIABLES

    [root@ol9apex24 ~]# su - oracle
    [oracle@ol9apex24 ~]$ mkdir /home/oracle/scripts
    [oracle@ol9apex24 ~]$ cat > /home/oracle/scripts/setEnv.sh <<EOF
    # Oracle Settings
    export TMP=/tmp
    export TMPDIR=\$TMP

    export ORACLE_HOSTNAME=ol7db1
    export ORACLE_UNQNAME=appscdb
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=\$ORACLE_BASE/product/23.5.0/dbhome_1
    export ORA_INVENTORY=/u01/app/oraInventory
    export ORACLE_SID=appscdb1

    export PATH=/usr/sbin:/usr/local/bin:\$PATH
    export PATH=\$ORACLE_HOME/bin:\$PATH

    export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
    export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
    EOF

    [oracle@ol9apex24 ~]$ echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile

    [oracle@ol9apex24 ~]$ cat > /home/oracle/scripts/start_all.sh <<EOF
	#!/bin/bash
	. /home/oracle/scripts/setEnv.sh

	export ORAENV_ASK=NO
	. oraenv
	export ORAENV_ASK=YES

	dbstart \$ORACLE_HOME
	EOF

    [oracle@ol9apex24 ~]$ cat > /home/oracle/scripts/stop_all.sh <<EOF
	#!/bin/bash
	. /home/oracle/scripts/setEnv.sh

	export ORAENV_ASK=NO
	. oraenv
	export ORAENV_ASK=YES

	dbshut \$ORACLE_HOME
	EOF

    [oracle@ol9apex24 ~]$ chown -R oracle:oinstall /home/oracle/scripts
    [oracle@ol9apex24 ~]$ chmod u+x /home/oracle/scripts/*.sh

###### DOWNLOAD ORACLE DATABASE SOFTWARE
   
    V1043785-01.zip

###### MOVE AND UNZIP DATABASE SOFTWARE
 
    [oracle@ol9apex24 ~]$ mv p37370465_230000_Linux-x86-64.zip /u01/app/oracle/product/23.7.0/dbhome_1/
    [oracle@ol9apex24 dbhome_1]$ gunzip p37370465_230000_Linux-x86-64.zip

###### CREATE db_install.rsp INSTALL RESPONSE FILE

    [oracle@ol9apex24 ~]$ vi db_install.rsp
                            oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v23.0.0
                            installOption=INSTALL_DB_SWONLY
                            UNIX_GROUP_NAME=oinstall
                            INVENTORY_LOCATION=/u01/app/oraInventory
                            ORACLE_HOME=/u01/app/oracle/product/23.5.0/dbhome_1
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
    [oracle@ol9apex24 ~]$ cd $ORACLE_HOME
    [oracle@ol9apex24 ~]$ ./runInstaller -silent -responseFile /home/oracle/db_install.rsp
    [oracle@ol9apex24 ~]$ exit
    [root@ol9apex24 ~]# /u01/app/oraInventory/orainstRoot.sh
    [root@ol9apex24 ~]# /u01/app/oracle/product/23.5.0/dbhome_1/root.sh

###### CREATE dbca.rsp response file

	[oracle@ol9apex24 ~]$ vi dbca.rsp
				responseFileVersion=/oracle/assistants/rspfmt_dbca_response_schema_v23.0.0
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
				templateName=/u01/app/oracle/product/23.5.0/dbhome_1/assistants/dbca/templates/General_Purpose.dbc
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
				variables=ORACLE_BASE_HOME=/u01/app/oracle/product/23.5.0/dbhome_1,DB_UNIQUE_NAME=appscdb,ORACLE_BASE=/u01/app/oracle,PDB_NAME=,DB_NAME=appscdb,ORACLE_HOME=/u01/app/oracle/product/23.5.0/dbhome_1,SID=appscdb1
				initParams=_exadata_feature_on=true,undo_tablespace=UNDOTBS1,sga_target=2047MB,db_block_size=8192BYTES,log_archive_dest_1='LOCATION={ORACLE_BASE}/oradata/archivelog/',nls_language=AMERICAN,dispatchers=(PROTOCOL=TCP) (SERVICE=appscdb1XDB),diagnostic_dest={ORACLE_BASE},control_files=("{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/control01.ctl", "{ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}/control02.ctl"),remote_login_passwordfile=EXCLUSIVE,audit_file_dest={ORACLE_BASE}/admin/{DB_UNIQUE_NAME}/adump,processes=600,pga_aggregate_target=683MB,nls_territory=AMERICA,db_recovery_file_dest_size=12732MB,open_cursors=300,log_archive_format=%t_%s_%r.dbf,compatible=23.0.0,db_name=appscdb,db_recovery_file_dest={ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME},audit_trail=db,_exadata_feature_on=true
				sampleSchema=false
				memoryPercentage=40
				databaseType=MULTIPURPOSE
				automaticMemoryManagement=false
				totalMemory=0

###### CREATE netca.rsp response file

	[oracle@ol9apex24 ~]$ vi netca.rsp
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

	[oracle@ol9apex24 ~]$ dbca -silent -createDatabase -responseFile /home/oracle/dbca.rsp

###### CREATE LISTENER

	[oracle@ol9apex24 ~]$ netca -silent -responsefile /home/oracle/netca.rsp

###### START LISTENER

	[oracle@ol9apex24 ~]$ lsnrctl status
 	LSNRCTL for Linux: Version 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on 15-FEB-2025 16:10:08

	Copyright (c) 1991, 2024, Oracle.  All rights reserved.

	Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
	STATUS of the LISTENER
	------------------------
	Alias                     LISTENER
	Version                   TNSLSNR for Linux: Version 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Start Date                15-FEB-2025 16:10:08
	Uptime                    0 days 0 hr. 0 min. 6 sec
	Trace Level               off
	Security                  ON: Local OS Authentication
	SNMP                      OFF
	Listener Log File         /u01/app/oracle/diag/tnslsnr/ol9apex24/listener/alert/log.xml
	Listening Endpoints Summary...
  	(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=ol9apex24)(PORT=1521)))
	The listener supports no services
	The command completed successfully

###### ENABLE AUTOMATIC START PDB

	[oracle@ol9apex24 ~]$ sqlplus / as sysdba

	SQL*Plus: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue Feb 18 16:20:09 2025
	Version 23.5.0.24.07

	Copyright (c) 1982, 2024, Oracle.  All rights reserved.


	Connected to:
	Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Version 23.5.0.24.07

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
    
	SQL> create tablespace APEX_DATA datafile '/u01/app/oracle/oradata/APPSCDB/appspdb/apex_data01.dbf' size 1g autoextend on next 50m maxsize 10g;

	Tablespace created.

	SQL> exit
	Disconnected from Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Version 23.5.0.24.07

###### CONFIGURE TNSNAMES.ORA

	[oracle@ol9apex24 ~]$ cat > /u01/app/oracle/product/23.5.0/dbhome_1/network/admin/tnsnames.ora <<EOF
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

	[root@ol9apex24 ~]# vi /etc/oratab
 				appscdb1:/u01/app/oracle/product/23.5.0/dbhome_1:Y

###### CONFIGURE ORACLE DATABASE DAEMON 

	[root@ol9apex24 ~]# vi /lib/systemd/system/dbora.service
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

	[root@ol9apex24 ~]# systemctl daemon-reload
	[root@ol9apex24 ~]# systemctl enable dbora.service

###### CREATE ORDS CONFIGURATION DIRECTORY
	
	[root@ol9apex24 ~]# mkdir -p /etc/ords/config
	[root@ol9apex24 ~]# mkdir -p /etc/ords/logs
	[root@ol9apex24 ~]# chown -R oracle:oinstall /etc/ords

###### SET JAVA_HOME ENVIRONMENT VARIABLES 

	[root@ol9apex24 ~]# vi .bash_profile
	export JAVA_HOME=/usr/lib/jvm/jdk-24.0.2-oracle-x64
	export PATH=$PATH:$JAVA_HOME/bin	
	[root@ol9apex24 ~]# source .bash_profile	

###### DOWNLOAD APEX AND ORDS

	[root@ol9apex24 ~]# su - oracle
	[oracle@ol9apex24 ~]$ wget https://download.oracle.com/otn_software/apex/apex_24.2.zip 
	[oracle@ol9apex24 ~]$ wget https://download.oracle.com/otn_software/java/ords/ords-25.2.2.204.0103.zip

###### CREATE APEX AND ORDS DIRECTORIES TO STORE SOFTWARE

	[oracle@ol9apex24 ~]$ mkdir -p /u01/app/oracle/ords
	[oracle@ol9apex24 ~]$ mkdir -p /u01/app/oracle/ords/images
	[oracle@ol9apex24 ~]$ mkdir -p /u01/app/oracle/apex 
	[oracle@ol9apex24 ~]$ mv apex_24.2.zip /u01/app/oracle/apex/
	[oracle@ol9apex24 ~]$ mv ords-25.2.2.204.0103.zip /u01/app/oracle/ords/	
	[oracle@ol9apex24 ~]$ cd /u01/app/oracle/ords
	[oracle@ol9apex24 ords]$ unzip ords-25.2.2.204.0103.zip
	[oracle@ol9apex24 ~]$ cd /u01/app/oracle/apex/ 
	[oracle@ol9apex24 apex]$ unzip apex_24.2.zip
	[oracle@ol9apex24 apex]$ cp -rp images /u01/app/oracle/ords

###### SETUP ORACLE APEX 

	[oracle@ol9apex24 apex]$ sqlplus / as sysdba

	SQL*Plus: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Wed Jul 30 20:04:12 2025
	Version 23.7.0.25.01

	Copyright (c) 1982, 2024, Oracle.  All rights reserved.

	Connected to:
	Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Version 23.7.0.25.01

	SQL> show pdbs

	    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
	---------- ------------------------------ ---------- ----------
		 2 PDB$SEED			  READ ONLY  NO
		 3 APPSPDB			  READ WRITE NO
	SQL> alter session set container = APPSPDB;

	Session altered.

	SQL> @apexins.sql APEX_DATA APEX_DATA TEMP /i/

	timing for: Validating Installation
	Elapsed:    0.02

	#
	# Actions in Phase 3:
	#
	    ok 1 - BEGIN							|   0.00
	    ok 2 - Updating DBA_REGISTRY					|   0.00
	    ok 3 - Computing Pub Syn Dependents 				|   0.00
	    ok 4 - Upgrade Hot Metadata and Switch Schemas			|   0.00
	    ok 5 - Removing Jobs						|   0.00
	    ok 6 - Creating Public Synonyms					|   0.02
	    ok 7 - Granting Public Synonyms					|   0.07
	    ok 8 - Granting to FLOWS_FILES					|   0.00
	    ok 9 - Creating FLOWS_FILES grants and synonyms			|   0.00
	    ok 10 - Syncing ORDS Gateway Allow List				|   0.00
	    ok 11 - Creating Jobs						|   0.00
	    ok 12 - Creating Dev Jobs						|   0.00
	    ok 13 - Installing FLOWS_FILES Objects				|   0.00
	    ok 14 - Installing APEX$SESSION Context				|   0.00
	    ok 15 - Recompiling APEX_240200					|   0.02
	    ok 16 - Installing APEX REST Config 				|   0.00
	    ok 17 - Set Loaded/Upgraded in Registry				|   0.00
	    ok 18 - Setting Patch Status: APPLIED				|   0.02
	    ok 19 - Removing Unused SYS Objects and Public Privs		|   0.00
	    ok 20 - Validating Installation					|   0.02
	ok 3 - 20 actions passed, 0 actions failed				|   0.13

	Thank you for installing Oracle APEX 24.2.0

	Oracle APEX is installed in the APEX_240200 schema.

	The structure of the link to the Oracle APEX Administration Services is as follows:
	http://host:port/ords/apex_admin

	The structure of the link to the Oracle APEX development environment is as follows:
	http://host:port/ords/apex


	timing for: Phase 3 (Switch)
	Elapsed:    0.13


	timing for: Complete Installation
	Elapsed:    4.88

	SYS> @apxchpwd.sql
	...set_appun.sql
	================================================================================
	This script can be used to change the password of an Oracle APEX
	instance administrator. If the user does not yet exist, a user record will be
	created.
	================================================================================
	Enter the administrator's username [ADMIN] ADMIN
	User "ADMIN" does not yet exist and will be created.
	Enter ADMIN's email [ADMIN] admin@exated.online
	Enter ADMIN's password [] 
	Created instance administrator ADMIN.

	SYS> @apex_rest_config.sql
	Enter a password for the APEX_LISTENER user              [] 
	Enter a password for the APEX_REST_PUBLIC_USER user              [] 
	...set_appun.sql
	...setting session environment
	...create APEX_LISTENER and APEX_REST_PUBLIC_USER users
	...grants for APEX_LISTENER and ORDS_METADATA user

	SYS> select username from dba_users where username like 'APEX%';

	USERNAME
	--------------------------------------------------------------------------------
	APEX_LISTENER
	APEX_PUBLIC_ROUTER
	APEX_REST_PUBLIC_USER
	APEX_PUBLIC_USER
	APEX_240200
	
	SYS> BEGIN
    	DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
        host => '*',
        ace => xs$ace_type(privilege_list => xs$name_list('connect'),
                           principal_name => 'APEX_240200',
                           principal_type => xs_acl.ptype_db));
	END;
	/
	
	SYS> select dbms_xdb.gethttpport from dual;

	GETHTTPPORT
	-----------
		  0
	
	SYS> exec dbms_xdb.sethttpport('8081');

	SYS> select dbms_xdb.gethttpport from dual;

	GETHTTPPORT
	-----------
	       8081

	SYS> exit
	Disconnected from Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Version 23.7.0.25.01

	[oracle@ol9apex24 apex]$ exit

###### SETUP ORACLE ORDS 

	[root@ol9apex24 ~]# /u01/app/oracle/ords/bin/ords --config /etc/ords/config install \
	--log-folder /etc/ords/logs \
	--admin-user SYS \
	--db-hostname ol9apex24.appsdba.info \
	--db-port 1521 \
	--db-servicename appspdb.appsdba.info \
	--feature-db-api true \
	--feature-rest-enabled-sql true \
	--feature-sdw true \
	--gateway-mode proxied \
	--gateway-user APEX_PUBLIC_USER \
	--proxy-user

###### CREATE GOLD IMAGE ORDS

	[root@ol9apex24 ~]# /u01/app/oracle/ords/bin/ords --config /etc/ords/config config set standalone.static.path /u01/app/oracle/ords/images

###### CREATE ORACLE REST DATA SERVICES DAEMON 

	[root@ol9apex24 ~]# vi /etc/systemd/system/ords.service
	[Unit]
	Description=Oracle REST Data Services
	After=network.target

	[Service]
	User=oracle
	Group=oinstall
	WorkingDirectory=/u01/app/oracle/ords
	ExecStart=/u01/app/oracle/ords/bin/ords --config /etc/ords/config serve
	Restart=always
	RestartSec=5s

	[Install]
	WantedBy=multi-user.target

	[root@ol9apex24 ~]# systemctl daemon-reload
	[root@ol9apex24 ~]# systemctl enable ords.service

###### ENABLE ORACLE START DAEMON

	[root@ol9apex24 ~]# visudo
	oracle ALL=(ALL) NOPASSWD: /bin/systemctl start ords.service, /bin/systemctl stop ords.service, /bin/systemctl restart ords.service, /bin/systemctl status ords.service

###### START ORACLE REST DATA SERVICES DAEMON 
	[root@ol9apex24 ~]# systemctl start ords.service
	[root@ol9apex24 ~]# systemctl status -l ords.service 
	● ords.service - Oracle REST Data Services
	     Loaded: loaded (/etc/systemd/system/ords.service; enabled; preset: disabled)
	     Active: active (running) since Wed 2025-07-30 19:17:26 -03; 1h 16min ago
	   Main PID: 4471 (ords)
	      Tasks: 46 (limit: 50355)
	     Memory: 804.6M
	        CPU: 21.368s
	     CGroup: /system.slice/ords.service
	             ├─4471 /bin/bash /u01/app/oracle/ords/bin/ords --config /etc/ords/config serve
	             └─4503 java -Doracle.dbtools.cmdline.home=/u01/app/oracle/ords -Duser.language=en -Duser.region=US -Dfile.encoding=UTF-8 -Djava.awt.headless=true --add-exports=java.base/jdk.internal.foreign=ALL-UNNAMED -Doracle.dbtools.cmdl>

	Jul 30 19:17:31 ol9apex24.appsdba.info ords[4503]: conf.use.wallet=true
	Jul 30 19:17:31 ol9apex24.appsdba.info ords[4503]: 2025-07-30T22:17:31.325Z WARNING     *** jdbc.MaxLimit in configuration |default|lo| is using a value of 10, this setting may not be sized adequately for a production environment ***
	Jul 30 19:17:31 ol9apex24.appsdba.info ords[4503]: 2025-07-30T22:17:31.659Z INFO        Created Pool: |default|lo|-2025-07-30T22-17-30.701942897Z at: 2025-07-30T22:17:30.701942897Z
	Jul 30 19:17:31 ol9apex24.appsdba.info ords[4503]: 2025-07-30T22:17:31.664Z INFO
	Jul 30 19:17:31 ol9apex24.appsdba.info ords[4503]: Mapped local pools from /etc/ords/config/databases:
	Jul 30 19:17:31 ol9apex24.appsdba.info ords[4503]:   /ords/                              => default                        => VALID
	Jul 30 19:17:31 ol9apex24.appsdba.info ords[4503]: 2025-07-30T22:17:31.742Z INFO        Oracle REST Data Services initialized
	Jul 30 19:17:31 ol9apex24.appsdba.info ords[4503]: Oracle REST Data Services version : 25.2.2.r2040103
	Jul 30 19:17:31 ol9apex24.appsdba.info ords[4503]: Oracle REST Data Services server info: jetty/12.0.18
	Jul 30 19:17:31 ol9apex24.appsdba.info ords[4503]: Oracle REST Data Services java info: Java HotSpot(TM) 64-Bit Server VM  (build 24.0.2+12-54 mixed mode, sharing)

###### ACCESS ORACLE ORDS

> *https://ol9apex24.appsdba.info:8080/ords*

![ol9apex24](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Apex_24.2/images/img1.png)









	




