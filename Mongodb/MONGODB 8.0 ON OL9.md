**MONGODB 8.0 ON OL9.5**

> *MongoDB 8, due out in October 2024, represents a significant evolution of the popular NoSQL database, with a focus on performance, security, scalability, and resilience.
> *- Improved Performance: MongoDB 8 delivers notable performance gains, including up to 36% faster reads, 56% faster bulk writes, and up to 200% faster aggregations on time-series data compared to version 7.0. Architectural optimizations have reduced memory usage and query times.*  
> *- Strengthened Security with Queryable Encryption: Queryable Encryption functionality has been expanded to support range queries on fully encrypted data. This allows you to work with sensitive data more efficiently while maintaining security at every stage.*    
> *- Easier and Faster Horizontal Scalability: The new version makes horizontal scaling easier and faster, with reduced upfront costs. Data resharding has also been significantly accelerated.*    
> *- Greater Control and Resilience: MongoDB 8 introduces new controls to optimize database performance during unpredictable peaks in usage, ensuring greater application resilience.*    
> *- Other Improvements: Version 8 also brings improvements to logging (with profiler configuration based on processing time), aggregation, replication (faster concurrent writes), and sharding (simplified conversion of sharded to non-sharded collections and more efficient collection movement).*

![oracle database 23ai logo.](https://github.com/danilo01arrudal/Documentation/blob/main/Mongodb/images/mongodb_logo)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER

    [root@exated ~]# virt-install --virt-type kvm --name ol9mongodb --memory 4096 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9mongodb.qcow2,size=50

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( DISABLE SELINUX ) 
   
    [root@ol9mongodb ~]# hostnamectl set-hostname ol9mongodb.appsdba.info

###### PRE REQUIREMENTS POSTGRES ENVIRONMENT ( CONFIGURE REPOSITORY )

    [root@ol9mongodb ~]# vi /etc/yum.repos.d/mongodb-org-8.0.repo
      [mongodb-org-8.0]
      name=MongoDB Repository
      baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/8.0/x86_64/
      gpgcheck=1
      enabled=1
      gpgkey=https://pgp.mongodb.com/server-8.0.asc

###### INSTALL MONGODB 8.0

    [root@ol9mongodb ~]# yum install -y mongodb-org

###### POST INSTALL MONGODB ( ENABLE AND START SERVICE ) 

    [root@ol9mongodb ~]# systemctl enable mongod; systemctl start mongod

###### POST INSTALL MONGODB ( GET STARTED ) 

    [root@ol9mongodb ~]# mongosh
    Current Mongosh Log ID:	67fc2e972bd7d19046d861df
    Connecting to:		mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.5.0
    Using MongoDB:		8.0.6
    Using Mongosh:		2.5.0

    For mongosh info see: https://www.mongodb.com/docs/mongodb-shell/


    To help improve our products, anonymous usage data is collected and sent to MongoDB periodically (https://www.mongodb.com/legal/privacy-policy).
    You can opt-out by running the disableTelemetry() command.

    ------
       The server generated these startup warnings when booting
       2025-04-13T18:06:31.629-03:00: Using the XFS filesystem is strongly recommended with the WiredTiger storage engine. See http://dochub.mongodb.org/core/prodnotes-filesystem
       2025-04-13T18:06:32.024-03:00: Access control is not enabled for the database. Read and write access to data and configuration is unrestricted
       2025-04-13T18:06:32.024-03:00: For customers running the current memory allocator, we suggest changing the contents of the following sysfsFile
       2025-04-13T18:06:32.024-03:00: For customers running the current memory allocator, we suggest changing the contents of the following sysfsFile
       2025-04-13T18:06:32.024-03:00: We suggest setting the contents of sysfsFile to 0.
       2025-04-13T18:06:32.024-03:00: vm.max_map_count is too low
       2025-04-13T18:06:32.024-03:00: We suggest setting swappiness to 0 or 1, as swapping can cause performance problems.
    ------

    test>

