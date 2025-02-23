**ORACLE DATABASE 23ai 2 NODE RAC MODE PLUS STORAGE ON OL9.5**

> *The main purpose of installing Oracle RAC is to provide high availability and horizontal scalability for Oracle databases. It allows multiple database instances to operate simultaneously on different servers, sharing the same data store. This ensures that, in the event of a server failure, the database remains accessible without interruption, and also allows processing capacity to be increased by adding new servers. Oracle RAC is ideal for mission-critical applications that require continuous performance and fault tolerance, optimizing resource utilization and improving response to increasing transaction demands.*

![oracle database 23ai logo.](https://github.com/danilo01arrudal/Exated/blob/main/Oracle_Database_23ai/images/1714697079871.png)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER OL9N1 

    virt-install --virt-type kvm --name ol9n1 --memory 8192 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --network bridge=br0,model=virtio --network network=priv0,model=virtio --disk path=/var/lib/libvirt/images/ol9n1.qcow2,size=59

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER OL9N2 

    virt-install --virt-type kvm --name ol9n2 --memory 8192 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --network bridge=br0,model=virtio --network network=priv0,model=virtio --disk path=/var/lib/libvirt/images/ol9n2.qcow2,size=59

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( DISABLE FIREWALL AND SELINUX )

    [root@ol9n1 ~]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    [root@ol9n2 ~]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

    [root@ol9n1 ~]# systemctl stop firewalld; systemctl disable firewalld 
    [root@ol9n2 ~]# systemctl stop firewalld; systemctl disable firewalld

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( PACKAGES )

    [root@ol9n1 ~]# yum install -y oracle-database-preinstall-23ai.x86_64
    [root@ol9n2 ~]# yum install -y oracle-database-preinstall-23ai.x86_64
    [root@ol9n1 ~]# yum install -y https://yum.oracle.com/repo/OracleLinux/OL9/addons/x86_64/getPackage/oracleasm-support-3.0.0-7.el9.x86_64.rpm
    [root@ol9n2 ~]# yum install -y https://yum.oracle.com/repo/OracleLinux/OL9/addons/x86_64/getPackage/oracleasm-support-3.0.0-7.el9.x86_64.rpm
    [root@ol9n1 ~]# rpm -ivh oracleasmlib-3.0.0-13.el9.x86_64.rpm
    [root@ol9n2 ~]# rpm -ivh oracleasmlib-3.0.0-13.el9.x86_64.rpm
    [root@ol9n1 ~]# yum install -y chkconfig
    [root@ol9n2 ~]# yum install -y chkconfig
    [root@ol9n1 ~]# yum install -y iscsi-initiator-utils udisks2-iscsi 
    [root@ol9n2 ~]# yum install -y iscsi-initiator-utils udisks2-iscsi 

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( PLUGGABLE AUTHENTICATION MODULES )

    [root@ol9n1 ~]# echo "session         required        pam_limits.so" >> /etc/pam.d/su 
    [root@ol9n1 ~]# echo "session         required        pam_unix.so" >> /etc/pam.d/su
    [root@ol9n2 ~]# echo "session         required        pam_limits.so" >> /etc/pam.d/su 
    [root@ol9n2 ~]# echo "session         required        pam_unix.so" >> /etc/pam.d/su 
    [root@ol9n1 ~]# echo "session    required     pam_limits.so" >> /etc/pam.d/sshd
    [root@ol9n1 ~]# echo "session    required     pam_unix.so" >> /etc/pam.d/sshd
    [root@ol9n2 ~]# echo "session    required     pam_limits.so" >> /etc/pam.d/sshd
    [root@ol9n2 ~]# echo "session    required     pam_unix.so" >> /etc/pam.d/sshd
    [root@ol9n1 ~]# echo "session    required     pam_limits.so" >> /etc/pam.d/login
    [root@ol9n1 ~]# echo "session    required     pam_unix.so" >> /etc/pam.d/login
    [root@ol9n2 ~]# echo "session    required     pam_limits.so" >> /etc/pam.d/login
    [root@ol9n2 ~]# echo "session    required     pam_unix.so" >> /etc/pam.d/login

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( SECURITY LIMITS )

    [root@ol9n1 ~]# cat <<EOF >> /etc/security/limits.conf
    *    hard    nofile     327680
    *    soft    nofile     262144
    *    hard    nproc      327680
    *    soft    nproc      262144
    *    hard    memlock    3145728
    *    soft    memlock    3145728
    *    hard    stack      16384
    *    soft    stack      10240
    EOF
    [root@ol9n2 ~]# cat <<EOF >> /etc/security/limits.conf
    *    hard    nofile     327680
    *    soft    nofile     262144
    *    hard    nproc      327680
    *    soft    nproc      262144
    *    hard    memlock    3145728
    *    soft    memlock    3145728
    *    hard    stack      16384
    *    soft    stack      10240
    EOF

###### PRE REQUIREMENTS ORACLE ENVIRONMENT ( CREATE USERS )

    [root@ol9n1 ~]# userdel oracle; rm -Rvf /home/oracle; rm -Rvf /var/mail/oracle 
    [root@ol9n2 ~]# userdel oracle; rm -Rvf /home/oracle; rm -Rvf /var/mail/oracle 
    [root@ol9n1 ~]# groupadd -g 54321 oinstall; groupadd -g 54322 dba; groupadd -g 54323 oper; groupadd -g 54324 backupdba; groupadd -g 54325 dgdba; groupadd -g 54326 kmdba; groupadd -g 54327 asmdba; groupadd -g 54328 asmoper; groupadd -g 54329 asmadmin; groupadd -g 54330 racdba; useradd -m -u 54331 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,asmdba,asmadmin,racdba -d /home/oracle -s /bin/bash  oracle; useradd -m -u 54332 -g oinstall -G dba,asmadmin,asmdba,asmoper -d /home/grid -s /bin/bash  grid; id oracle; id grid
    [root@ol9n2 ~]# groupadd -g 54321 oinstall; groupadd -g 54322 dba; groupadd -g 54323 oper; groupadd -g 54324 backupdba; groupadd -g 54325 dgdba; groupadd -g 54326 kmdba; groupadd -g 54327 asmdba; groupadd -g 54328 asmoper; groupadd -g 54329 asmadmin; groupadd -g 54330 racdba; useradd -m -u 54331 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,asmdba,asmadmin,racdba -d /home/oracle -s /bin/bash  oracle; useradd -m -u 54332 -g oinstall -G dba,asmadmin,asmdba,asmoper -d /home/grid -s /bin/bash  grid; id oracle; id grid
    [root@ol9n1 ~]# passwd oracle
    [root@ol9n2 ~]# passwd oracle
    [root@ol9n1 ~]# passwd grid
    [root@ol9n2 ~]# passwd grid


