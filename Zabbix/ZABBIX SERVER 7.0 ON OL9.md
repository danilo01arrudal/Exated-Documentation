**ZABBIX SERVER 7.0 ON OL9**

> *Zabbix is ​​an enterprise-grade, open-source monitoring solution that monitors the availability and performance of IT infrastructures, including networks, servers, virtual machines, services, applications, and the cloud. It collects and displays basic metrics, enabling users to proactively detect problems and ensure the reliability of their systems.*

![zabbix logo.](https://github.com/danilo01arrudal/Documentation/blob/main/Zabbix/images/zabbix_logo_icon_168734.png)

##### Install Zabbix Repository

    [root@ol9dns ~]# rpm -Uvh https://repo.zabbix.com/zabbix/7.0/rhel/9/x86_64/zabbix-release-latest.el9.noarch.rpm

##### Update your system’s repository

    [root@ol9dns ~]# dnf clean all

##### Install Zabbix Server, Frontend, and Agent

    [root@ol9dns ~]# dnf install zabbix-server-mysql zabbix-sql-scripts zabbix-web-mysql zabbix-apache-conf zabbix-agent -y

##### Install and Configure MySQL Database

    [root@ol9dns ~]# dnf -y install mysql-server
    [root@ol9dns ~]# systemctl enable --now mysqld

##### Secure the MySQL installation

    [root@ol9dns ~]# mysql_secure_installation

    Securing the MySQL server deployment.

    Connecting to MySQL using a blank password.

    VALIDATE PASSWORD COMPONENT can be used to test passwords
    and improve security. It checks the strength of password
    and allows the users to set only those passwords which are
    secure enough. Would you like to setup VALIDATE PASSWORD component?

    Press y|Y for Yes, any other key for No: y

    There are three levels of password validation policy:

    LOW    Length >= 8
    MEDIUM Length >= 8, numeric, mixed case, and special characters
    STRONG Length >= 8, numeric, mixed case, special characters and dictionary                  file

    Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG: 2
    Please set the password for root here.

    New password: 

    Re-enter new password: 

    Estimated strength of the password: 100 
    Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) : y
    By default, a MySQL installation has an anonymous user,
    allowing anyone to log into MySQL without having to have
    a user account created for them. This is intended only for
    testing, and to make the installation go a bit smoother.
    You should remove them before moving into a production
    environment.

    Remove anonymous users? (Press y|Y for Yes, any other key for No) : y
    Success.


    Normally, root should only be allowed to connect from
    'localhost'. This ensures that someone cannot guess at
    the root password from the network.

    Disallow root login remotely? (Press y|Y for Yes, any other key for No) : y
    Success.

    By default, MySQL comes with a database named 'test' that
    anyone can access. This is also intended only for testing,
    and should be removed before moving into a production
    environment.


    Remove test database and access to it? (Press y|Y for Yes, any other key for No) : y
    - Dropping test database...
    Success.

    - Removing privileges on test database...
    Success.

    Reloading the privilege tables will ensure that all changes
    made so far will take effect immediately.

    Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y
    Success.

    All done!

##### Create a database and user for Zabbix

    [root@ol9dns ~]# mysql -u root -p
    Enter password: 
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 13
    Server version: 8.0.41 Source distribution

    Copyright (c) 2000, 2025, Oracle and/or its affiliates.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql> CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    Query OK, 1 row affected (0,02 sec)

    mysql> CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'FbU580>I';
    Query OK, 0 rows affected (0,01 sec)

    mysql> GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost'; 
    Query OK, 0 rows affected (0,01 sec)

    mysql> FLUSH PRIVILEGES;
    Query OK, 0 rows affected (0,01 sec)

    mysql> SET GLOBAL log_bin_trust_function_creators = 1; 
    Query OK, 0 rows affected, 1 warning (0,00 sec)

    mysql> EXIT;
    Bye

##### Import Initial Schema and Data

    [root@ol9dns ~]# zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -u zabbix -p zabbix
    Enter password:

##### Configure Zabbix Server

    DBHost=localhost
    DBName=zabbix
    DBUser=zabbix
    DBPassword=FbU580>I
    NodeAddress=localhost:10051

##### Configure PHP for Zabbix Frontend

    [root@ol9dns ~]# vi /etc/php.ini
    date.timezone = America/Fortaleza

##### Start and Enable Apache to apply the changes:

    [root@ol9dns ~]# systemctl enable --now httpd

##### Start Zabbix Server and Agent

    [root@ol9dns ~]# systemctl enable --now zabbix-server zabbix-agent

##### Configure Firewall 

    [root@ol9dns ~]# firewall-cmd --permanent --add-port=10051/tcp
    [root@ol9dns ~]# firewall-cmd --permanent --add-service=http
    [root@ol9dns ~]# firewall-cmd --reload

##### Configure SELinux for the Zabbix Frontend

    [root@ol9dns ~]# setsebool -P httpd_can_network_connect on

##### Access Zabbix Web Interface

    http://192.168.18.201/zabbix/setup.php

##### Zabbix Frontend Setup

##### Log into the Zabbix frontend 

    http://192.168.18.201/zabbix/setup.php
    user : Admin
    password : zabbix 








