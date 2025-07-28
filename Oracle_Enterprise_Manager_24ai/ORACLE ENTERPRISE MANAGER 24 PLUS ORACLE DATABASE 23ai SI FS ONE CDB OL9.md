**ORACLE ENTERPRISE MANAGER 24ai PLUS ORACLE DATABASE 23ai SI FS ONE CDB OL9.5**


> *Oracle Enterprise Manager 24ai is Oracle's modern management platform, enhanced with AI for managing Oracle Databases and Engineered Systems across on-premises and cloud. Key features include an AI-powered assistant, zero downtime monitoring and job system, highly available remote agents, container-based architecture, improved UI, and integration with OCI observability and AI services for enhanced insights, automation, and security.*

![oracle enterprise manager_24ai logo.](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24ai/images/images.png)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER
    
    [root@exated ~]# virt-install --virt-type kvm --name ol9em24ai --memory 8192 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9em24ai.qcow2,size=100 

###### CONFIGURE HOSTNAME

    [root@ol9em24ai ~]# hostnamectl set-hostname ol9em24ai

###### INSTALL PRE-INSTALL PACKAGES

    [root@ol9em24ai ~]# dnf install -y oracle-database-preinstall-23ai
    [root@ol9em24ai ~]# dnf install -y make
    [root@ol9em24ai ~]# dnf install -y binutils
    [root@ol9em24ai ~]# dnf install -y gcc
    [root@ol9em24ai ~]# dnf install -y libaio
    [root@ol9em24ai ~]# dnf install -y libstdc++
    [root@ol9em24ai ~]# dnf install -y sysstat
    [root@ol9em24ai ~]# dnf install -y glibc-devel
    [root@ol9em24ai ~]# dnf install -y glibc-common
    [root@ol9em24ai ~]# dnf install -y libXtst
    [root@ol9em24ai ~]# dnf install -y libnsl


###### DISABLE SELINUX

    [root@ol9em24ai ~]# sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config && setenforce 0

###### SETTING CLOCK SOURCE FOR VMs ON LINUX x86-64

    [root@ol923ai ~]# echo "tsc" > /sys/devices/system/clocksource/clocksource0/current_clocksource

###### CONFIGURE STATIC NETWORK

    [root@ol9em24ai ~]# nmcli device 
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    lo      loopback  connected (externally)  lo  

    [root@ol9em24ai ~]# nmcli connection show  
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  26097519-1cba-3447-8711-fb0800ba2366  ethernet  enp1s0 
    lo      7ac75b97-ee60-4288-90d8-a732972b360f  loopback  lo 

    [root@ol9em24ai ~]# nmcli con modify 'enp1s0' iframe enp1s0 ipv4.method manual ipv4.addresses 192.168.18.16/24 gw4 192.168.18.1
    [root@ol9em24ai ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.201
    [root@ol9em24ai ~]# nmcli con down 'enp1s0'
    [root@ol9em24ai ~]# nmcli con up 'enp1s0'

    [root@ol9em24ai ~]# ip addr show enp1s0
    2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:84:74:c7 brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.16/24 brd 192.168.18.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever

    [root@ol9em24ai ~]# ip route show
    default via 192.168.18.1 dev enp1s0 proto static metric 100 
    192.168.18.0/24 dev enp1s0 proto kernel scope link src 192.168.18.16 metric 100 

###### CREATE ORACLE_BASE AND ORACLE_HOME DIRECTORIES

    [root@ol9em24ai ~]# mkdir -p /u01/app/oracle/product/23.7.0/dbhome_1/
    [root@ol9em24ai ~]# chown -R oracle:oinstall /u01
    [root@ol9em24ai ~]# chmod -R 775 /u01

###### CONFIGURE VARIABLES

    [root@ol9em24ai ~]# su - oracle
    [oracle@ol9em24ai ~]$ mkdir /home/oracle/scripts
    [oracle@ol9em24ai ~]$ cat > /home/oracle/scripts/setEnv.sh <<EOF
    # Oracle Settings
    export TMP=/tmp
    export TMPDIR=\$TMP

    export ORACLE_HOSTNAME=ol9em24ai
    export ORACLE_UNQNAME=appscdb
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=\$ORACLE_BASE/product/23.7.0/dbhome_1
    export ORA_INVENTORY=/u01/app/oraInventory
    export ORACLE_SID=appscdb

    export PATH=/usr/sbin:/usr/local/bin:\$PATH
    export PATH=\$ORACLE_HOME/bin:\$PATH

    export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
    export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
    EOF

    [oracle@ol9em24ai ~]$ echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile

    [oracle@ol9em24ai ~]$ cat > /home/oracle/scripts/start_all.sh <<EOF
    #!/bin/bash
    /home/oracle/scripts/setEnv.sh

    export ORAENV_ASK=NO
    . oraenv
    export ORAENV_ASK=YES

    dbstart \$ORACLE_HOME
    EOF

    [oracle@ol9em24ai ~]$ cat > /home/oracle/scripts/stop_all.sh <<EOF
    #!/bin/bash
    . /home/oracle/scripts/setEnv.sh

    export ORAENV_ASK=NO
    . oraenv
    export ORAENV_ASK=YES

    dbshut \$ORACLE_HOME
    EOF

    [oracle@ol9em24ai ~]$ chown -R oracle:oinstall /home/oracle/scripts
    [oracle@ol9em24ai ~]$ chmod u+x /home/oracle/scripts/*.sh

###### DOWNLOAD ORACLE DATABASE SOFTWARE
   
    V1043785-01.zip

###### MOVE AND UNZIP DATABASE SOFTWARE
 
    [oracle@ol9em24ai ~]$ mv p37370465_230000_Linux-x86-64.zip /u01/app/oracle/product/23.7.0/dbhome_1/
    [oracle@ol9em24ai dbhome_1]$ gunzip p37370465_230000_Linux-x86-64.zip

###### CREATE db_install.rsp INSTALL RESPONSE FILE

    [root@ol9em24ai ~]# vi db_install.rsp
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

	[oracle@ol9em24ai ~]$ cd $ORACLE_HOME
	[oracle@ol9em24ai ~]$ ./runInstaller -silent -responseFile /home/oracle/db_install.rsp
	[oracle@ol9em24ai ~]$ exit
	[root@ol9em24ai ~]# /u01/app/oraInventory/orainstRoot.sh
	[root@ol9em24ai ~]# /u01/app/oracle/product/23.7.0/dbhome_1/root.sh

###### CREATE dbca.rsp response file

	[oracle@ol923ai ~]$ vi dbca.rsp
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
                        initParams=undo_tablespace=UNDOTBS1,enable_pluggable_database=true,sga_target=2379MB,db_block_size=8192BYTES,nls_language=AMERICAN,dispatchers=(PROTOCOL=TCP) (SERVICE=appscdbXDB),diagnostic_dest={ORACLE_BASE},control_files=("{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/control01.ctl", "{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/control02.ctl"),remote_login_passwordfile=EXCLUSIVE,_exadata_feature_on=true,processes=300,pga_aggregate_target=793MB,nls_territory=AMERICA,open_cursors=300,db_domain=appsdba.info,compatible=23.6.0,db_name=appscdb
                        enableArchive=false
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

###### CREATE DATABASE 

	[oracle@ol923ai ~]$ dbca -silent -createDatabase -responseFile /home/oracle/dbca.rsp

###### CREATE LISTENER

	[oracle@ol923ai ~]$ netca -silent -responsefile /home/oracle/netca.rsp

###### START LISTENER

	[oracle@ol9em24ai ~]$ lsnrctl start

	LSNRCTL for Linux: Version 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on 28-JUL-2025 14:34:40

	Copyright (c) 1991, 2024, Oracle.  All rights reserved.

	Starting /u01/app/oracle/product/23.7.0/dbhome_1/bin/tnslsnr: please wait...

	TNSLSNR for Linux: Version 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Log messages written to /u01/app/oracle/diag/tnslsnr/ol9em24ai/listener/alert/log.xml
	Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=ol9em24ai.appsdba.info)(PORT=1521)))

	Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
	STATUS of the LISTENER
	------------------------
	Alias                     LISTENER
	Version                   TNSLSNR for Linux: Version 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Start Date                28-JUL-2025 14:34:40
	Uptime                    0 days 0 hr. 0 min. 0 sec
	Trace Level               off
	Security                  ON: Local OS Authentication
	SNMP                      OFF
	Listener Log File         /u01/app/oracle/diag/tnslsnr/ol9em24ai/listener/alert/log.xml
	Listening Endpoints Summary...
	  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=ol9em24ai.appsdba.info)(PORT=1521)))
	The listener supports no services
	The command completed successfully

###### ENABLE AUTOMATIC START PDB

	[oracle@ol9em24ai ~]$ sqlplus / as sysdba

	SQL*Plus: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Mon Jul 28 14:35:29 2025
	Version 23.7.0.25.01

	Copyright (c) 1982, 2024, Oracle.  All rights reserved.


	Connected to:
	Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Version 23.7.0.25.01

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
	Disconnected from Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Version 23.7.0.25.01

###### RECOMMENDED MINIMUM SETTINGS ON ORACLE DATABASE

	[oracle@ol9em24ai ~]$ sqlplus / as sysdba

	SQL*Plus: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Mon Jul 28 14:39:16 2025
	Version 23.7.0.25.01

	Copyright (c) 1982, 2024, Oracle.  All rights reserved.


	Connected to:
	Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Version 23.7.0.25.01

	SQL> alter system set "_allow_insert_with_update_check"=true scope=both;

	System altered.

	SQL> alter system set session_cached_cursors=200 scope=spfile;

	System altered.

	SQL> alter system set processes=600 scope=spfile;

	System altered.

	SQL> alter system set pga_aggregate_target=450M scope=spfile;

	System altered.

	SQL> alter system set sga_target=800M scope=spfile;

	System altered.

	SQL> alter system set shared_pool_size=600M scope=spfile;

	System altered.

	SQL> SHUTDOWN IMMEDIATE;
	Database closed.
	Database dismounted.
	ORACLE instance shut down.
	SQL> STARTUP;
	ORACLE instance started.

	Total System Global Area  835901400 bytes
	Fixed Size		    5429208 bytes
	Variable Size		  633339904 bytes
	Database Buffers	  188743680 bytes
	Redo Buffers		    8388608 bytes
	Database mounted.
	Database opened.
	SQL> exit
	Disconnected from Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Version 23.7.0.25.01

###### CONFIGURE TNSNAMES.ORA

	[oracle@ol923ai ~]$ cat > /u01/app/oracle/product/23.7.0/dbhome_1/network/admin/tnsnames.ora <<EOF
	appspdb =
	(DESCRIPTION =
	(ADDRESS_LIST =
	(ADDRESS = (PROTOCOL = TCP)(HOST = ol9em24ai.appsdba.info)(PORT = 1521))
	)
	(CONNECT_DATA =
	(SERVICE_NAME = appspdb.appsdba.info)
	)
	)

	appscdb =
	(DESCRIPTION =
	(ADDRESS_LIST =
	(ADDRESS = (PROTOCOL = TCP)(HOST = ol9em24ai.appsdba.info)(PORT = 1521))
	)
	(CONNECT_DATA =
	(SERVICE_NAME = appscdb.appsdba.info)
	)
	)
	EOF  

###### AUTOMATIC START SERVICE ORACLE

	[root@ol923ai ~]# vi /etc/oratab
 				appscdb1:/u01/app/oracle/product/23.7.0/dbhome_1:Y

###### ENTERPRISE MANAGER 24ai DOWNLOAD UNZIP AND INSTALLATION

	Oracle Enterprise Manager 24ai Release 1 for Linux x86-64 bit

	This document contains information on the Oracle Enterprise Manager 24ai Release 1 Shiphome extraction information.

	Extraction of Oracle Enterprise Manager 24ai Release 1 Shiphome
	============================================================================================================

	Downloading the files
	---------------------
	1. Download the all shiphome zips files, for each platform there are 5 files example as shown below
	/scratch/V1046984-01.zip
	/scratch/V1046951-01.zip
	/scratch/V1046951-02.zip
	/scratch/V1046951-03.zip
	/scratch/V1046951-04.zip
	/scratch/V1046951-05.zip

	2. The downloaded files are compressed with the zip format. Use any unzip tool to uncompress the file, or download a utility from eDelivery http://updates.oracle.com/unzips/unzips.html. This will generate the compressed zip files.

	# cd /scratch
	
	#unzip V1046984-01.zip
	#unzip V1046951-01.zip
	#unzip V1046951-02.zip
	#unzip V1046951-03.zip
	#unzip V1046951-04.zip
	#unzip V1046951-05.zip

	Uncompressing the .zip files will create shiphome files ending with .bin & .zip extension.

	3. Start installation using the executable binary

	For example
	# ./em24100_linux64.bin

	Follow the install flow as provided in the Enterprise Manager Basic Installation Guide.

###### GRANT EXECUTE ENTERPRISE MANAGER 24ai BINARY

	[oracle@ol9em24ai ~]$ cd /tmp/emcc/
	[oracle@ol9em24ai emcc]$ chmod u+x em24100_linux64.bin

###### CREATE ENTERPRISE MANAGER 24ai DIRECTORIES

	[oracle@ol9em24ai emcc]$ mkdir -p /u01/app/oracle/middleware
	[oracle@ol9em24ai emcc]$ mkdir -p /u01/app/oracle/agent

###### RUN EMCC 24AI INSTALLER

    [root@ol9em24ai ~]# xhost + 
    [root@ol9em24ai ~]# su - oracle
    [oracle@ol923ai ~]$ export DISPLAY=:0.0
    [oracle@ol923ai ~]$ cd /tmp/emcc
    [oracle@ol923ai ~]$ ./em13200_linux64.bin

![emcc24ai1](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24ai/images/img1.png)

![emcc24ai2](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24ai/images/img2.png)

![emcc24ai3](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24ai/images/img3.png)

![emcc24ai4](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24ai/images/img4.png)

![emcc24ai5](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24ai/images/img5.png)

![emcc24ai6](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24ai/images/img6.png)

![emcc24ai7](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24ai/images/img7.png)

![emcc24ai8](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24ai/images/img8.png)

![emcc24ai9](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24ai/images/img9.png)










