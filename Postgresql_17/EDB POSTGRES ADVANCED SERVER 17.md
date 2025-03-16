**EDB POSTGRES ADVANCED SERVER 17**

> *The main purpose of installing PostgreSQL 17 is to provide a robust, reliable, open-source relational database management system (RDBMS) for a variety of applications.
> *- Data management: PostgreSQL enables you to store, organize, and manage large volumes of data efficiently and securely.*  
> *- Diverse applications: It is suitable for a wide range of applications, from small personal projects to large enterprise systems, including web, mobile, data analysis, and scientific applications.*    
> *- Advanced features: PostgreSQL offers advanced features such as transactional integrity (ACID), concurrency, replication, security, and extensibility, making it a popular choice for mission-critical applications.*    
> *- Community and support: As an open source project, PostgreSQL has an active community of developers and users, which ensures ongoing support, updates, and improvements.*    
> *- Updates and improvements: Postgres 17 brings with it performance and security improvements over previous versions.*

![edb postgres logo.](https://github.com/danilo01arrudal/Documentation/blob/main/Postgresql_17/images/edb_postgres.jpeg)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER 

    [root@exated ~]# virt-install --virt-type kvm --name ol9pgedb --memory 4096 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9pgedb.qcow2,size=50
