**ORACLE DATABASE 19C ENABLE ARCHIVE LOG MODE**

> *Oracle Database lets you save filled groups of redo log files to one or more offline destinations, known collectively as the archived redo log.*

> *The process of turning redo log files into archived redo log files is called archiving. This process is only possible if the database is running in ARCHIVELOG mode. You can choose automatic or manual archiving.*

> *An archived redo log file is a copy of one of the filled members of a redo log group. It includes the redo entries and the unique log sequence number of the identical member of the redo log group.*
> *For example, if you are multiplexing your redo log, and if group 1 contains identical member files a_log1 and b_log1, then the archiver process (ARCn) will archive one of these member files.*
> *Should a_log1 become corrupted, then ARCn can still archive the identical b_log1. The archived redo log contains a copy of every group created since you enabled archiving.* 

> *When the database is running in ARCHIVELOG mode, the log writer process (LGWR) cannot reuse and hence overwrite a redo log group until it has been archived.*
> *The background process ARCn automates archiving operations when automatic archiving is enabled.*
> *The database starts multiple archiver processes as needed to ensure that the archiving of filled redo logs does not fall behind.*

> *You can use archived redo log files to:*

>> *Recover a database*

>> *Update a standby database*

>> *Get information about the history of a database using the LogMiner utility*

###### NOTE

> *"In Oracle multitenent database we have redo logs present at container database, there is no redo logs at pluggable database."*

![oracle database 19c logo](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Database_19c/images/oracle_database_19c_logo.png) 

###### CHECK ENVIRONMENT

> *Check the current environment configuration*

       [oracle@ol719csi ~]$ sqlplus / as sysdba

       SQL*Plus: Release 19.0.0.0.0 - Production on Tue Nov 4 11:37:31 2025
       Version 19.3.0.0.0

       Copyright (c) 1982, 2019, Oracle.  All rights reserved.

       Connected to:
       Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production Version 19.3.0.0.0

       SQL> select GROUP#, THREAD#, SEQUENCE#, BYTES, ARC, STATUS, NEXT_TIME from v$log;
       GROUP#     THREAD#    SEQUENCE#       BYTES  BLOCKSIZE    MEMBERS ARC STATUS           NEXT_TIME
       ---------- ---------- ---------- ---------- ---------- ---------- --- ---------------- ---------
                1          1         13  209715200        512          1 YES INACTIVE         04-NOV-25
                2          1         14  209715200        512          1 NO  CURRENT          
                3          1         12  209715200        512          1 YES INACTIVE         03-NOV-25

       SQL> select GROUP#, STATUS, MEMBER   * from v$logfile;
       GROUP#      STATUS MEMBER                                        
       ---------- ------- ----------------------------------------------
              3    ONLINE  /u01/app/oracle/oradata/APPSCDB/redo03.log   
              2    ONLINE  /u01/app/oracle/oradata/APPSCDB/redo02.log   
              1    ONLINE  /u01/app/oracle/oradata/APPSCDB/redo01.log   
   
       SQL> select name,open_mode,log_mode from v$database;
       NAME	    OPEN_MODE	           LOG_MODE
       --------- -------------------- ------------
       APPSCDB   READ WRITE	         NOARCHIVELOG

       SQL> archive log list
       Database log mode	        No Archive Mode
       Automatic archival	        Disabled
       Archive destination	        USE_DB_RECOVERY_FILE_DEST
       Oldest online log sequence   5
       Current log sequence	        7

> *Before enabling archiving, first we need to set the archive log destination where you want to save your archive logs*

> *By default oracle save archive log files in DB_RECOVERY_FILE_DEST location if set.*

> *It is possible to define a custom address for recording archivelogs by configuring the parameter DB_RECOVERY_FILE_DEST.*

       SQL> show parameter DB_RECOVERY_FILE_DEST;
       NAME                                 TYPE        VALUE
       ------------------------------------ ----------- -----------------------------------
       db_recovery_file_dest                string      /u01/app/oracle/fast_recovery_area                                               
       db_recovery_file_dest_size           big integer 12732M

       SQL> !ls -ltr /u01/app/oracle/fast_recovery_area/APPSCDB/
       total 18296
       drwxr-x---. 2 oracle oinstall     4096 Oct 28 15:15 onlinelog
       drwxr-x---. 5 oracle oinstall     4096 Nov  4 11:22 archivelog
       -rw-r-----. 1 oracle oinstall 18726912 Nov  4 11:40 control02.ctl

###### CONFIGURATION

> *Below are the parameters required to enable archivelog mode.*

>> *LOG_ARCHIVE_DEST_1 defines the address where the archives will be copied.*

>> *LOG_ARCHIVE_FORMAT allows customization of the name and extension of the archivelog files.*

       SQL> ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=USE_DB_RECOVERY_FILE_DEST' SCOPE=spfile;
       SQL> ALTER SYSTEM SET LOG_ARCHIVE_FORMAT='%t_%s_%r.arc' SCOPE=spfile;

###### RESTART ENVIRONMENT

> *For the parameters to be applied, a restart of the database instance is necessary. We are modifying static parameters that affect how the instance works.*

> *The environment must be started in mount mode:

>> *Mount mode in an Oracle database is an intermediate state during the database startup process, where an instance is started and associated with a database, but the database itself is not yet open for general user access. 

       SQL> shu immediate; 
       Database closed.
       Database dismounted.
       ORACLE instance shut down.

       SQL> startup mount;       
       ORACLE instance started.
       Total System Global Area 2147482944 bytes
       Fixed Size		    9137472 bytes
       Variable Size		  486539264 bytes
       Database Buffers	 1644167168 bytes
       Redo Buffers		    7639040 bytes
       Database mounted.

       SQL> select name,open_mode from v$pdbs;
       NAME        OPEN_MODE
       ----------- ---------------------------
       PDB$SEED    MOUNTED
       APPSPDB     MOUNTED

> *Place the database in ARCHIVELOG mode*

       SQL> alter database archivelog;
       Database altered.

> *Start the instance, and mount and open the database. This can be done in unrestricted mode, allowing access to all users, or in restricted mode, allowing access for database administrators only.*

       SQL> alter database open;
       Database altered.

       SQL> select name,open_mode from v$pdbs;

       NAME				 OPEN_MODE
       ------------ --------------------------
       PDB$SEED		 READ ONLY
       APPSPDB 		 MOUNTED

       SQL> alter session set container=APPSPDB;      
       Session altered.

       SQL> alter database open;
       Database altered.

###### VALIDATE THE ADJUST

       SQL> archive log list;
       Database log mode	          Archive Mode
       Automatic archival	          Enabled
       Archive destination	          /u02/app/oracle/oradata/APPSCDB/archivelog
       Oldest online log sequence    7
       Next log sequence to archive  9
       Current log sequence	      9

> *It is not possible to execute the switch logfile command connected to a pluggable database*

       SQL> alter system switch logfile;
       alter system switch logfile
       *
       ERROR at line 1:
       ORA-65040: operation not allowed from within a pluggable database

       SQL> alter session set container=CDB$ROOT;
       Session altered.

       SQL> alter system switch logfile;
       System altered.

       SQL> !ls -ltr /u01/app/oracle/fast_recovery_area/APPSCDB/archivelog/2025_11_04/
       total 4592
       -rw-r----- 1 oracle oinstall 2330112 Nov  4 11:40 o1_mf_1_11_njkydmqy_.arc
       -rw-r----- 1 oracle oinstall 2368000 Nov  4 11:41 o1_mf_1_12_njkzvonr_.arc










   
   

