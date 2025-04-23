**ORACLE ENTERPRISE MANAGER 24ai PLUS ORACLE DATABASE 23ai SI FS ONE CDB SILENT MODE OL9.5**


> *Oracle Enterprise Manager 24ai is Oracle's modern management platform, enhanced with AI for managing Oracle Databases and Engineered Systems across on-premises and cloud. Key features include an AI-powered assistant, zero downtime monitoring and job system, highly available remote agents, container-based architecture, improved UI, and integration with OCI observability and AI services for enhanced insights, automation, and security.*

![oracle enterprise manager_24ai logo.](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24ai/images/images.png)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER
    
    [root@exated ~]# virt-install --virt-type kvm --name ol9d --memory 4096 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9d.qcow2,size=50

###### CONFIGURE HOSTNAME

    [root@ol9em24ai ~]# hostnamectl set-hostname ol9em24ai

###### INSTALL PRE-INSTALL PACKAGES

    [root@ol9em24ai ~]# yum install oracle-database-preinstall-23ai

###### DISABLE SELINUX

    [root@ol9em24ai ~]# sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config && setenforce 0

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

###### DISABLE AVAHI DAEMON

    [root@ol9em24ai ~]# systemctl disable avahi-daemon  

###### INSTALL PACKAGES

    [root@ol9em24ai ~]# yum install make -y
    [root@ol9em24ai ~]# yum install binutils -y
    [root@ol9em24ai ~]# yum install gcc -y
    [root@ol9em24ai ~]# yum install libaio -y
    [root@ol9em24ai ~]# yum install glibc-common -y
    [root@ol9em24ai ~]# yum install libstdc++ -y
    [root@ol9em24ai ~]# yum install sysstat -y
    [root@ol9em24ai ~]# yum install glibc -y
    [root@ol9em24ai ~]# yum install glibc-devel.i686 -y
    [root@ol9em24ai ~]# yum install glibc-devel -y
    [root@ol9em24ai ~]# yum install libXtst -y

###### DISABLE AVAHI DAEMON

    [root@ol9em24ai ~]# systemctl stop avahi-daemon
    [root@ol9em24ai ~]# systemctl disable avahi-daemon

###### CONFIGURE CHRONY SERVICE

    [root@ol9em24ai ~]# yum install -y install chrony
    [root@ol9em24ai ~]# systemctl start chronyd
    [root@ol9em24ai ~]# systemctl enable chronyd

###### CONFIGURE PARAVIRTUALIZED CLOCK

    [root@ol9em24ai ~]# echo "tsc" > /sys/devices/system/clocksource/clocksource0/current_clocksource	

###### CREATE ORACLE_BASE AND ORACLE_HOME DIRECTORIES

    [root@ol9em24ai ~]# mkdir -p /u01/app/oracle/product/23.5.0/dbhome_1/
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
    export ORACLE_HOME=\$ORACLE_BASE/product/23.5.0/dbhome_1
    export ORA_INVENTORY=/u01/app/oraInventory
    export ORACLE_SID=appscdb1

    export PATH=/usr/sbin:/usr/local/bin:\$PATH
    export PATH=\$ORACLE_HOME/bin:\$PATH

    export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
    export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
    EOF

    [oracle@ol9em24ai ~]$ echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile

    [oracle@ol9em24ai ~]$ cat > /home/oracle/scripts/start_all.sh <<EOF
				#!/bin/bash
				. /home/oracle/scripts/setEnv.sh

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
 
    [oracle@ol9em24ai ~]$ mv V1043785-01.zip /u01/app/oracle/product/23.5.0/dbhome_1/
    [oracle@ol9em24ai dbhome_1]$ gunzip V1043785-01.zip 

###### CREATE db_install.rsp INSTALL RESPONSE FILE

    [root@ol9em24ai ~]# vi db_install.rsp
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

	[oracle@ol9em24ai ~]$ cd $ORACLE_HOME
	[oracle@ol9em24ai ~]$ ./runInstaller -silent -responseFile /home/oracle/db_install.rsp
	[oracle@ol9em24ai ~]$ exit
	[root@ol9em24ai ~]# /u01/app/oraInventory/orainstRoot.sh
	[root@ol9em24ai ~]# /u01/app/oracle/product/23.5.0/dbhome_1/root.sh

###### ENTERPRISE MANAGER 24ai DOWNLOAD UNZIP AND INSTALLATION

	Oracle Enterprise Manager 24ai Release 1 for Linux x86-64 bit

	This document contains information on the Oracle Enterprise Manager 24ai Release 1 Shiphome extraction information.

	Extraction of Oracle Enterprise Manager 24ai Release 1 Shiphome
	============================================================================================================

	Downloading the files
	---------------------
	1. Download the all shiphome zips files, for each platform there are 5 files example as shown below

	/scratch/V1046951-01.zip
	/scratch/V1046951-02.zip
	/scratch/V1046951-03.zip
	/scratch/V1046951-04.zip
	/scratch/V1046951-05.zip

	2. The downloaded files are compressed with the zip format. Use any unzip tool to uncompress the file, or download a utility from eDelivery http://updates.oracle.com/unzips/unzips.html. This will generate the compressed zip files.

	# cd /scratch

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



