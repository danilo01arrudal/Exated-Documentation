**ORACLE INSTANT CLIENT 23 SILENT MODE OL9.5**


> *The main purpose of installing an Oracle Instant Client is to provide a robust and scalable platform for data management. It allows companies to store, organize and access information efficiently, ensuring data integrity and security. In addition, Oracle offers advanced features for application development and data analysis, aiding in strategic decision-making.*

![oracle database 23ai logo.](https://github.com/danilo01arrudal/Exated/blob/main/Oracle_Database_23ai/images/1714697079871.png)

###### DOWNLOAD THE SOFTWARE

      [root@ol9client ~]# wget https://download.oracle.com/otn_software/linux/instantclient/2370000/oracle-instantclient-odbc-23.7.0.25.01-1.el9.x86_64.rpm
      [root@ol9client ~]# wget https://download.oracle.com/otn_software/linux/instantclient/2370000/oracle-instantclient-jdbc-23.7.0.25.01-1.el9.x86_64.rpm
      [root@ol9client ~]# wget https://download.oracle.com/otn_software/linux/instantclient/2370000/oracle-instantclient-devel-23.7.0.25.01-1.el9.x86_64.rpm
      [root@ol9client ~]# wget https://download.oracle.com/otn_software/linux/instantclient/2370000/oracle-instantclient-sqlplus-23.7.0.25.01-1.el9.x86_64.rpm
      [root@ol9client ~]# wget https://download.oracle.com/otn_software/linux/instantclient/2370000/oracle-instantclient-basic-23.7.0.25.01-1.el9.x86_64.rpm

      [root@ol9client ~]# ls -ltr /tmp/
         -rw-r--r--. 1 root         root         79460281 Mar 25 22:33 oracle-instantclient-basic-23.7.0.25.01-1.el9.x86_64.rpm
         -rw-r--r--. 1 root         root           687141 Mar 25 22:33 oracle-instantclient-devel-23.7.0.25.01-1.el9.x86_64.rpm
         -rw-r--r--. 1 root         root          1544481 Mar 25 22:33 oracle-instantclient-jdbc-23.7.0.25.01-1.el9.x86_64.rpm
         -rw-r--r--. 1 root         root           266682 Mar 25 22:33 oracle-instantclient-odbc-23.7.0.25.01-1.el9.x86_64.rpm
         -rw-r--r--. 1 root         root          2711122 Mar 25 22:33 oracle-instantclient-sqlplus-23.7.0.25.01-1.el9.x86_64.rpm

###### INSTALL THE SOFTWARE

      [root@ol9client ~]# cd /tmp/
      [root@ol9client tmp]# rpm -ivh oracle-instantclient-basic-23.7.0.25.01-1.el9.x86_64.rpm 
         Verifying...                          ################################# [100%]
         Preparing...                          ################################# [100%]
         Updating / installing...
            1:oracle-instantclient-basic-23.7.0################################# [100%]
      [root@ol9client tmp]# rpm -ivh oracle-instantclient-devel-23.7.0.25.01-1.el9.x86_64.rpm 
         Verifying...                          ################################# [100%]
         Preparing...                          ################################# [100%]
         Updating / installing...
            1:oracle-instantclient-devel-23.7.0################################# [100%]
      [root@ol9client tmp]# rpm -ivh oracle-instantclient-jdbc-23.7.0.25.01-1.el9.x86_64.rpm 
         Verifying...                          ################################# [100%]
         Preparing...                          ################################# [100%]
         Updating / installing...
            1:oracle-instantclient-jdbc-23.7.0.################################# [100%]
      [root@ol9client tmp]# rpm -ivh oracle-instantclient-odbc-23.7.0.25.01-1.el9.x86_64.rpm 
         Verifying...                          ################################# [100%]
         Preparing...                          ################################# [100%]
         Updating / installing...
            1:oracle-instantclient-odbc-23.7.0.################################# [100%]
      [root@ol9client tmp]# rpm -ivh oracle-instantclient-sqlplus-23.7.0.25.01-1.el9.x86_64.rpm 
         Verifying...                          ################################# [100%]
         Preparing...                          ################################# [100%]
         Updating / installing...
            1:oracle-instantclient-sqlplus-23.7################################# [100%]
      [root@ol9client tmp]# 

###### CREATE A TNSNAMES FILE

      [root@ol9client ~]# vi /usr/lib/oracle/23/client64/lib/network/admin/tnsnames.ora 
         HR =
        (DESCRIPTION =
          (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.18.21)(PORT = 5444))
          (CONNECT_DATA =
            (SERVER = DEDICATED)
            (SERVICE_NAME = hr)
          )
        )

###### TEST AND VALIDATE THE CONNECTION STRING

      [root@ol9client ~]# sqlplus enterprisedb/enterprisedb@HR
