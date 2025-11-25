**ORACLE DATABASE 19C ENABLE ARCHIVE LOG MODE**

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

###### CHECK ENVIRONMENT
