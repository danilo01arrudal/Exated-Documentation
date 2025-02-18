**ORACLE DATABASE 23ai SI FS ONE CDB SILENT MODE OL9.5**

> The main purpose of installing an Oracle database is to provide a robust and scalable platform for data management. It allows companies to store, organize and access information efficiently, ensuring data integrity and security. In addition, Oracle offers advanced features for application development and data analysis, aiding in strategic decision-making.

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER
    
    [root@exated ~]# virt-install --virt-type kvm --name ol9 --memory 4096 --vcpus 2 --os-variant ol9.5 --cdrom /root/Downloads/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9.qcow2,size=50

###### CONFIGURE HOSTNAME

    [root@ ~]# hostnamectl set-hostname ol923ai

###### INSTALL PRE-INSTALL PACKAGES

    [root@ol923ai ~]# yum install oracle-database-preinstall-23ai

###### DISABLE SELINUX

    [root@ol923ai ~]# sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config && setenforce 0

###### CONFIGURE STATIC NETWORK
    
    [root@ol923ai ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    lo      loopback  connected (externally)  lo   

    [root@ol923ai ~]# nmcli connection show 
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  82e45657-ca14-380d-adfc-ac71a5aa7281  ethernet  enp1s0 
    lo      c30f3777-2d34-40f9-9fdb-da73383b9848  loopback  lo  

    [root@ol923ai ~]# nmcli con modify 'enp1s0' iframe enp1s0 ipv4.method manual ipv4.addresses 192.168.18.101/24 gw4 192.168.18.1
    [root@ol923ai ~]# nmcli con modify 'enp1s0' ipv4.dns 192.168.18.201
    [root@ol923ai ~]# nmcli con down 'enp1s0'
    [root@ol923ai ~]# nmcli con up 'enp1s0'

    [root@ol923ai ~]# ip addr show enp1s0
    2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:bc:5a:a4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.18.101/24 brd 192.168.18.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever
    inet6 2804:248:f65e:2800:5054:ff:febc:5aa4/64 scope global dynamic noprefixroute 
       valid_lft 86197sec preferred_lft 86197sec
    inet6 fe80::5054:ff:febc:5aa4/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever

    [root@ol923ai ~]# ip route show
    default via 192.168.18.1 dev enp1s0 proto static metric 100 
    192.168.18.0/24 dev enp1s0 proto kernel scope link src 192.168.18.101 metric 100 

###### CREATE ORACLE_BASE AND ORACLE_HOME DIRECTORIES

    [root@ol923ai ~]# mkdir -p /u01/app/oracle/product/23.5.0/dbhome_1/
    [root@ol923ai ~]# chown -R oracle:oinstall /u01
    [root@ol923ai ~]# chmod -R 775 /u01

###### CONFIGURE VARIABLES

    [root@ol923ai ~]# su - oracle
    [oracle@ol923ai ~]$ mkdir /home/oracle/scripts
    [oracle@ol923ai ~]$ cat > /home/oracle/scripts/setEnv.sh <<EOF
				# Oracle Settings
				export TMP=/tmp
				export TMPDIR=\$TMP

				export ORACLE_HOSTNAME=ol7db1
				export ORACLE_UNQNAME=appscdb
				export ORACLE_BASE=/u01/app/oracle
				export ORACLE_HOME=\$ORACLE_BASE/product/19.3.0/dbhome_1
				export ORA_INVENTORY=/u01/app/oraInventory
				export ORACLE_SID=appscdb1

				export PATH=/usr/sbin:/usr/local/bin:\$PATH
				export PATH=\$ORACLE_HOME/bin:\$PATH

				export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
				export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
				EOF

    [oracle@ol923ai ~]$ echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile

    [oracle@ol923ai ~]$ cat > /home/oracle/scripts/start_all.sh <<EOF
				#!/bin/bash
				. /home/oracle/scripts/setEnv.sh

				export ORAENV_ASK=NO
				. oraenv
				export ORAENV_ASK=YES

				dbstart \$ORACLE_HOME
				EOF

    [oracle@ol923ai ~]$ cat > /home/oracle/scripts/stop_all.sh <<EOF
				#!/bin/bash
				. /home/oracle/scripts/setEnv.sh

				export ORAENV_ASK=NO
				. oraenv
				export ORAENV_ASK=YES

				dbshut \$ORACLE_HOME
				EOF

    [oracle@ol923ai ~]$ chown -R oracle:oinstall /home/oracle/scripts
    [oracle@ol923ai ~]$ chmod u+x /home/oracle/scripts/*.sh

###### DOWNLOAD ORACLE DATABASE SOFTWARE
   
    V1043785-01.zip

###### MOVE AND UNZIP DATABASE SOFTWARE
 
    [oracle@ol923ai ~]$ mv V1043785-01.zip /u01/app/oracle/product/23.5.0/dbhome_1/
    [oracle@ol923ai dbhome_1]$ gunzip V1043785-01.zip 

###### CREATE db_install.rsp INSTALL RESPONSE FILE

    [oracle@ol923ai ~]$ vi db_install.rsp
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
    [oracle@ol923ai ~]$ cd $ORACLE_HOME
    [oracle@ol923ai ~]$ ./runInstaller -silent -responseFile /home/oracle/db_install.rsp
    [oracle@ol923ai ~]$ exit
    [root@ol923ai ~]# /u01/app/oraInventory/orainstRoot.sh
    [root@ol923ai ~]# /u01/app/oracle/product/23.5.0/dbhome_1/root.sh

###### CREATE dbca.rsp response file

	[oracle@ol923ai ~]$ vi dbca.rsp
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
				initParams=_exadata_feature_on=true,undo_tablespace=UNDOTBS1,sga_target=2047MB,db_block_size=8192BYTES,log_archive_dest_1='LOCATION={ORACLE_BASE}/oradata/archivelog/',nls_language=AMERICAN,dispatchers=(PROTOCOL=TCP) (SERVICE=appscdb1XDB),diagnostic_dest={ORACLE_BASE},control_files=("{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/control01.ctl", "{ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}/control02.ctl"),remote_login_passwordfile=EXCLUSIVE,audit_file_dest={ORACLE_BASE}/admin/{DB_UNIQUE_NAME}/adump,processes=600,pga_aggregate_target=683MB,nls_territory=AMERICA,db_recovery_file_dest_size=12732MB,open_cursors=300,log_archive_format=%t_%s_%r.dbf,compatible=23.0.0,db_name=appscdb,db_recovery_file_dest={ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME},audit_trail=db
				sampleSchema=false
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


###### writed by: Danilo Arruda
###### ter 18 fev 2025
