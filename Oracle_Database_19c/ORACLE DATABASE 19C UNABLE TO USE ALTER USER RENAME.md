**ORACLE DATABASE 19C UNABLE TO USE ALTER USER RENAME**

> *In Oracle 19c, directly renaming an existing schema (which is synonymous with a user) using ALTER USER RENAME is no longer supported.*
> *This functionality was removed in 19c, and attempting to execute this command will result in an error.*
> *To effectively "change" a schema name in Oracle 19c, the common approach involves creating a new user and migrating the objects from the old schema to the new one*

.

.

.

.

.

.

.

.

.

.

.

.

.

###### CREATE USER AND TRY RENAME 

        [oracle@ol719csi ~]$ sqlplus / as sysdba

            SQL*Plus: Release 19.0.0.0.0 - Production on Tue Nov 25 15:20:30 2025
            Version 19.3.0.0.0

            Copyright (c) 1982, 2019, Oracle.  All rights reserved.


            Connected to:
            Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
            Version 19.3.0.0.0

            SQL> show pdbs;

                CON_ID CON_NAME                       OPEN MODE  RESTRICTED
            ---------- ------------------------------ ---------- ----------
                     2 PDB$SEED                       READ ONLY  NO
                     3 APPSPDB                        READ WRITE NO

            SQL> alter session set container=APPSPDB;

            Session altered.

            SQL> create user EXATED identified by "exated";

            User created.

            SQL> grant connect, resource to EXATED;

            Grant succeeded.

            SQL> alter session set "_enable_rename_user"=true;

            Session altered.

            SQL> alter system enable restricted session;

            System altered.

            SQL> alter user "EXATED" rename to "EXA" identified by "exated";
            alter user "EXATED" rename to "EXA" identified by "exated"
                    *
            ERROR at line 1:
            ORA-03001: unimplemented feature

            SQL> alter system disable restricted session;

            System altered.

            SQL> exit
            Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
            Version 19.3.0.0.0

> *This procedure worked for Oracle Database 12c and Oracle Database 18c environments.* 
> *You cannot directly rename a user in Oracle 19c.* 
> *The ALTER USER RENAME command is no longer supported. To change a username,* 
> *you must create a new user and grant the necessary privileges to the new user,* 
> *then export the old user's data and import it into the new user account.* 
> *Finally, you can drop the original user.* 


###### Copyright © 2025 by Exated Software Ltda

