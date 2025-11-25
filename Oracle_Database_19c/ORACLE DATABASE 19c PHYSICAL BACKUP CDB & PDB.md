**ORACLE DATABASE 19c PHYSICAL BACKUP CDB & PDB**

> *Full Backup: Copies all data blocks from a tablespace or the entire database.*

> *Incremental Backup: Copies only the blocks that have changed since the last backup (whether Full or Incremental). This saves time and space, making it essential for large databases.*

> *Backup Format: RMAN creates backup sets, which are one or more backup files in a proprietary, compressed format. It can also create image copies, which are exact copies of the database files in the original operating system format.* 

> *Recovery: RMAN tracks all backups and restore/recovery operations in the RMAN Catalog or the target database's control file. This simplifies recovery because RMAN knows exactly which files and logs are needed and in what order.*

> *Advantages:*

>> *Consistency: Ensures that the backup is consistent, even if the database is open and in use (Hot Backup).*

>> *Optimization: Allows for compression and backup of unused blocks (block-level media recovery), making the process more efficient.*

>> *Verification: RMAN can validate backups to ensure they are not corrupted before a restore.*

> *RMAN is Oracle's recommended tool for backups and recovery due to its integration, efficiency, and advanced features.*

###### NOTE

> *" The routine performs three tasks, two daily, and the afternoon task is only performed on Sundays."*

> *" A full Sunday backup, incremental backups on other days of the week, and archive backups every two hours."*

> *"Routines can be scheduled in crontab or Oracle schedules jobs."*

###### CRONTAB SCHEDULE

    [oracle@ol719csi ~]$ crontab -l
      30 00 * * 6             su - oracle -c /backup/scripts/bkp_level0.sh
      30 00 * * 0,1,2,3,4,5   su - oracle -c /backup/scripts/bkp_level2.sh
      00 02,04,06,08,10,12,14,16,18,20,22 * * * su - oracle -c /backup/scripts/bkp_archive.sh

> *The scheduling configuration in crontab depends on the characteristics of your environment.*

###### CREATE DIRECTORIES

    [root@ol719csi ~]# mkdir -p /backup
    [root@ol719csi ~]# chown oracle:oinstall -R /backup
    [root@ol719csi ~]# su - oracle
    [oracle@ol719csi ~]$ mkdir -p /backup/scripts
    [oracle@ol719csi ~]$ mkdir -p /backup/logs
    [oracle@ol719csi ~]$ mkdir -p /backup/control
    [oracle@ol719csi ~]$ mkdir -p /backup/rman/dados/cdb
    [oracle@ol719csi ~]$ mkdir -p /backup/rman/dados/root
    [oracle@ol719csi ~]$ mkdir -p /backup/rman/dados/pdb
    [oracle@ol719csi ~]$ mkdir -p /backup/rman/archives

###### SCRIPT FULL BACKUP CDB + PDBS

    [oracle@ol719csi ~]$ vi /backup/scripts/bkp_level0.sh
      export data=$(date +"_%Y%m%d%H%M%S")
      rman target / log=/backup/logs/full_$data.log cmdfile=/backup/scripts/bkp_level0.rman
      find /backup/control/ -name "control*.bkp" -mtime +7 -exec rm -vf {} \;

    [oracle@ol719csi ~]$ vi /backup/scripts/bkp_level0.rman
      RUN
      {
      CROSSCHECK BACKUP;
      CROSSCHECK ARCHIVELOG ALL;
      BACKUP AS COMPRESSED BACKUPSET INCREMENTAL LEVEL=0 DATABASE TAG='BKP_FULL' FORMAT '/backup/rman/dados/cdb/DADOS_FULL_%D_%Y%M%D_%U.BKP';
      BACKUP AS COMPRESSED BACKUPSET ARCHIVELOG ALL DELETE ALL INPUT FORMAT '/backup/rman/archives/ARC_%D_%Y%M%D_%U.BKP' TAG='BKP_ARC';
      COPY CURRENT CONTROLFILE TO '/backup/control/CONTROL01_%D_%Y%M%D.BKP';
      DELETE NOPROMPT OBSOLETE;
      }

###### GRANT EXECUTION

    [oracle@ol719csi ~]$ chmod +x /backup/scripts/bkp_level0.sh
    
###### SCRIPT INCREMENTAL BACKUP CDB + PDBS

    [oracle@ol719csi ~]$ vi /backup/scripts/bkp_level2.sh
      export data=$(date +"_%Y%m%d%H%M%S")
      rman target / log=/backup/logs/incremental_$data.log cmdfile=/backup/scripts/bkp_level2.rman

    [oracle@ol719csi ~]$ vi /backup/scripts/bkp_level2.rman
      RUN
      {
      CROSSCHECK BACKUP;
      CROSSCHECK ARCHIVELOG ALL;
      BACKUP AS COMPRESSED BACKUPSET INCREMENTAL LEVEL=2 CUMULATIVE DATABASE TAG='BKP_CUM' FORMAT '/backup/rman/dados/cdb/DADOS_CUM_%D_%Y%M%D_%U.BKP';
      BACKUP AS COMPRESSED BACKUPSET ARCHIVELOG ALL DELETE ALL INPUT FORMAT '/backup/rman/archives/ARC_%D_%Y%M%D.BKP_%U' TAG='BKP_ARC';
      COPY CURRENT CONTROLFILE TO '/backup/control/CONTROL01_%D_%Y%M%D.BKP';
      DELETE NOPROMPT OBSOLETE;
      }

###### GRANT EXECUTION

    [oracle@ol719csi ~]$ chmod +x /backup/scripts/bkp_level2.sh

###### SCRIPT BACKUP ARCHIVELOG

    [oracle@ol719csi ~]$ vi /backup/scripts/bkp_archive.sh
      export data=$(date +"_%Y%m%d%H%M%S")
      rman target / log=/backup/logs/archive_$data.log cmdfile=/backup/scripts/bkp_archive.rman

    [oracle@ol719csi ~]$ vi /backup/scripts/bkp_archive.rman
      RUN
      {
      CROSSCHECK ARCHIVELOG ALL;
      BACKUP AS COMPRESSED BACKUPSET ARCHIVELOG ALL DELETE ALL INPUT FORMAT '/backup/rman/archives/ARC_%D_%Y%M%D_%U.BKP' TAG='BKP_ARC';
      COPY CURRENT CONTROLFILE TO '/backup/control/CONTROL01_%D_%Y%M%D.BKP';
      DELETE NOPROMPT OBSOLETE;
      }

###### GRANT EXECUTION

    [oracle@ol719csi ~]$ chmod +x /backup/scripts/bkp_archive.sh
    
###### NOTE

> *Beyond backup setup it is necessary to parameter the backup full retention that is the main resume consumer on server.*
> *Oracle allows to configure this retention automatically by two parameters or command line on linux.*

> > *CONFIGURE RETENTION POLICY TO REDUNDANCY 1;  --- WILL KEEP ONLY THE LAST SUCCESSFUL BACKUP FULL*

> > *CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;  --- WILL KEEP ULTIMATE FULL BACKUP SUCCESSFUL FOR 7 DAYS*

> > *CONFIGURE DEFAULT DEVICE TYPE TO DISK;  -- DEFINES THAT THE BACKUP WILL BE WRITTEN TO DISK*

> > *CONFIGURE CONTROLFILE AUTOBACKUP ON;  -- CONFIGURE AUTOMATIC BACKUP OF CONTROLFILE*

> > *CONFIGURE DEVICE TYPE DISK PARALLELISM 4 BACKUP TYPE TO BACKUPSET; -- AUTOMATIC CHANNEL DEVICE CONFIGURATION AND PARALLELISM*

###### SET RMAN CONFIGURATION

    [oracle@ol719csi ~]$ rman target /

      Recovery Manager: Release 19.0.0.0.0 - Production on Tue Nov 25 13:04:05 2025
      Version 19.3.0.0.0

      Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

      connected to target database: APPSCDB (DBID=4059180582)

      RMAN> CONFIGURE RETENTION POLICY TO REDUNDANCY 1;

      using target database control file instead of recovery catalog
      new RMAN configuration parameters:
      CONFIGURE RETENTION POLICY TO REDUNDANCY 1;
      new RMAN configuration parameters are successfully stored

      RMAN> CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;

      old RMAN configuration parameters:
      CONFIGURE RETENTION POLICY TO REDUNDANCY 1;
      new RMAN configuration parameters:
      CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;
      new RMAN configuration parameters are successfully stored

      RMAN> CONFIGURE DEFAULT DEVICE TYPE TO DISK;

      new RMAN configuration parameters:
      CONFIGURE DEFAULT DEVICE TYPE TO DISK;
      new RMAN configuration parameters are successfully stored

      RMAN> CONFIGURE CONTROLFILE AUTOBACKUP ON;

      new RMAN configuration parameters:
      CONFIGURE CONTROLFILE AUTOBACKUP ON;
      new RMAN configuration parameters are successfully stored

      RMAN> CONFIGURE DEVICE TYPE DISK PARALLELISM 4 BACKUP TYPE TO BACKUPSET;

      new RMAN configuration parameters:
      CONFIGURE DEVICE TYPE DISK PARALLELISM 4 BACKUP TYPE TO BACKUPSET;
      new RMAN configuration parameters are successfully stored

      RMAN> exit

###### CHECK NEW CONFIGURATION

    [oracle@ol719csi ~]$ rman target /

      Recovery Manager: Release 19.0.0.0.0 - Production on Tue Nov 25 13:45:22 2025
      Version 19.3.0.0.0

      Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

      connected to target database: APPSCDB (DBID=4059180582)

      RMAN> show all;

      using target database control file instead of recovery catalog
      RMAN configuration parameters for database with db_unique_name APPSCDB are:
      CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;
      CONFIGURE BACKUP OPTIMIZATION OFF; # default
      CONFIGURE DEFAULT DEVICE TYPE TO DISK;
      CONFIGURE CONTROLFILE AUTOBACKUP ON;
      CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '%F'; # default
      CONFIGURE DEVICE TYPE DISK PARALLELISM 4 BACKUP TYPE TO BACKUPSET;
      CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
      CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
      CONFIGURE MAXSETSIZE TO UNLIMITED; # default
      CONFIGURE ENCRYPTION FOR DATABASE OFF; # default
      CONFIGURE ENCRYPTION ALGORITHM 'AES128'; # default
      CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE ; # default
      CONFIGURE RMAN OUTPUT TO KEEP FOR 7 DAYS; # default
      CONFIGURE ARCHIVELOG DELETION POLICY TO NONE; # default
      CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/u01/app/oracle/product/19.3.0/dbhome_1/dbs/snapcf_appscdb1.f'; # default

      RMAN> exit

###### EXTRA BACKUPS (IF NECESSARY)

> > > **BACKUP ONLY ROOT CONTAINER BACKUP**

    [oracle@ol719csi ~]$ rman target /

      Recovery Manager: Release 19.0.0.0.0 - Production on Tue Nov 25 14:50:23 2025
      Version 19.3.0.0.0

      Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

      connected to target database: APPSCDB (DBID=4059180582)

      RMAN> BACKUP DATABASE ROOT;

> > > **BACKUP ONLY OR MULTIPLE PLUGGABLES DATABASES**

    [oracle@ol719csi ~]$ rman target /

      Recovery Manager: Release 19.0.0.0.0 - Production on Tue Nov 25 14:50:23 2025
      Version 19.3.0.0.0

      Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

      connected to target database: APPSCDB (DBID=4059180582)

      RMAN> BACKUP PLUGGABLE DATABASE appspdb, fusionpdb;
