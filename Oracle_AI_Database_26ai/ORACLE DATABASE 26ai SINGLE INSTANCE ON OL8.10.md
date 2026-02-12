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

    [root@ol826ai ~]# mkdir -p /u01/app/oracle/product/23.5.0/dbhome_1/
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
    export ORACLE_SID=appscdb1

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
   
    V1043785-01.zip

###### MOVE AND UNZIP DATABASE SOFTWARE
 
    [oracle@ol826ai ~]$ mv V1043785-01.zip /u01/app/oracle/product/23.5.0/dbhome_1/
    [oracle@ol826ai dbhome_1]$ gunzip V1043785-01.zip 

###### CREATE db_install.rsp INSTALL RESPONSE FILE

    [oracle@ol826ai ~]$ vi db_install.rsp
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
    [oracle@ol826ai ~]$ cd $ORACLE_HOME
    [oracle@ol826ai ~]$ ./runInstaller -silent -responseFile /home/oracle/db_install.rsp
    [oracle@ol826ai ~]$ exit
    [root@ol826ai ~]# /u01/app/oraInventory/orainstRoot.sh
    [root@ol826ai ~]# /u01/app/oracle/product/23.5.0/dbhome_1/root.sh

###### CREATE dbca.rsp response file

	[oracle@ol826ai ~]$ vi dbca.rsp
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

	[oracle@ol826ai ~]$ vi netca.rsp
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

	[oracle@ol826ai ~]$ dbca -silent -createDatabase -responseFile /home/oracle/dbca.rsp

###### CREATE LISTENER

	[oracle@ol826ai ~]$ netca -silent -responsefile /home/oracle/netca.rsp

###### START LISTENER

	[oracle@ol826ai ~]$ lsnrctl status
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
	Listener Log File         /u01/app/oracle/diag/tnslsnr/ol826ai/listener/alert/log.xml
	Listening Endpoints Summary...
  	(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=ol826ai)(PORT=1521)))
	The listener supports no services
	The command completed successfully

###### ENABLE AUTOMATIC START PDB

	[oracle@ol826ai ~]$ sqlplus / as sysdba

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
    
	SQL> exit
	Disconnected from Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Version 23.5.0.24.07

###### CONFIGURE TNSNAMES.ORA

	[oracle@ol826ai ~]$ cat > /u01/app/oracle/product/23.5.0/dbhome_1/network/admin/tnsnames.ora <<EOF
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

	[root@ol826ai ~]# vi /etc/oratab
 				appscdb1:/u01/app/oracle/product/23.5.0/dbhome_1:Y

###### CONFIGURE ORACLE DATABASE DAEMON 

	[root@ol826ai ~]# vi /lib/systemd/system/dbora.service
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

	[root@ol826ai ~]# systemctl daemon-reload
	[root@ol826ai ~]# systemctl enable dbora.service

###### writed by: Danilo Arruda
###### ter 18 fev 2025
