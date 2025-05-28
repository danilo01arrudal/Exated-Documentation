# ZFS PLUS STORAGE ON OL9.5

> *ZFS (Zettabyte File System) is a combined file system and logical volume manager designed for high data integrity, scalability, and advanced features like snapshots and compression. It allows creating block devices (zvols) that can be shared over a network using iSCSI.*

>    *(1) ZFS turns a Linux server into a flexible storage server with built-in redundancy and data protection.*

>    *(2) It allows exposing zvols as iSCSI targets for remote access by other computers (initiators).*

![oracle linux iscsi logo.](https://github.com/danilo01arrudal/Exated/blob/main/Scsi/images/iSCSI.png)

> *ZFS provides advanced storage management capabilities, making it ideal for enterprise storage solutions.*

>    *Data Integrity: Uses checksums to detect and correct data corruption automatically.*

>    *Snapshots: Enables instantaneous point-in-time copies of volumes for backups or testing.*

>    *Compression: Supports inline compression (e.g., lz4) to save storage space.*

>    *Pool Expansion: Allows adding more disks to increase capacity or redundancy without downtime.*

>    *Thin Provisioning: Allocates storage dynamically, optimizing disk usage.*

###### INSTALL ZFS AND TARGETCLI

    [root@exated ~]# yum install -y zfs targetcli

###### CONFIGURE ZFS POOL AND VOLUMES

    [root@exated ~]# zpool create -f zpool_lun_storage mirror /dev/nvme0n1 /dev/nvme1n1
    [root@exated ~]# zfs set compression=lz4 zpool_lun_storage
    [root@exated ~]# zfs create -V 20G zpool_lun_storage/lun0
    [root@exated ~]# zfs create -V 20G zpool_lun_storage/lun1
    [root@exated ~]# zfs create -V 20G zpool_lun_storage/lun2
    [root@exated ~]# zfs create -V 20G zpool_lun_storage/lun3
    [root@exated ~]# zfs create -V 20G zpool_lun_storage/lun4
    [root@exated ~]# zfs list -t volume
    NAME                       USED  AVAIL  REFER  MOUNTPOINT
    zpool_lun_storage/lun0    20G   1.83T   20G   -
    zpool_lun_storage/lun1    20G   1.83T   20G   -
    zpool_lun_storage/lun2    20G   1.83T   20G   -
    zpool_lun_storage/lun3    20G   1.83T   20G   -
    zpool_lun_storage/lun4    20G   1.83T   20G   -

> *targetcli is a command-line interface for configuring the Linux Target Subsystem (LIO), enabling a Linux server to expose ZFS volumes as iSCSI targets over an IP network.*

>    *Creating iSCSI Targets: Configures iSCSI targets for remote storage access by initiators.*

>    *Managing LUNs: Maps ZFS volumes to Logical Unit Numbers (LUNs) for initiator access.*

>    *Access Control: Defines which initiators can access specific LUNs via ACLs.*

>    *Protocol Support: Supports iSCSI and other protocols like Fibre Channel.*

###### INSTALL AND CONFIGURE TARGETCLI

    [root@exated ~]# systemctl start target.service
    [root@exated ~]# systemctl enable target.service
    [root@exated ~]# targetcli
    targetcli shell version 2.1.57
    Copyright 2011-2013 by Datera, Inc and others.
    For help on commands, type 'help'.

    /> ls
    o- / ......................................................................................................................... [...]
      o- backstores .............................................................................................................. [...]
      | o- block .................................................................................................. [Storage Objects: 0]
      | o- fileio ................................................................................................. [Storage Objects: 0]
      | o- pscsi .................................................................................................. [Storage Objects: 0]
      | o- ramdisk ................................................................................................ [Storage Objects: 0]
      o- iscsi ............................................................................................................ [Targets: 0]
      o- loopback ......................................................................................................... [Targets: 0]
      o- vhost ............................................................................................................ [Targets: 0]
    /> cd /backstores/block
    /backstores/block> create name=lun0 dev=/dev/zvol/zpool_lun_storage/lun0
    Created block storage object lun0 using /dev/zvol/zpool_lun_storage/lun0.
    /backstores/block> create name=lun1 dev=/dev/zvol/zpool_lun_storage/lun1
    Created block storage object lun1 using /dev/zvol/zpool_lun_storage/lun1.
    /backstores/block> create name=lun2 dev=/dev/zvol/zpool_lun_storage/lun2
    Created block storage object lun2 using /dev/zvol/zpool_lun_storage/lun2.
    /backstores/block> create name=lun3 dev=/dev/zvol/zpool_lun_storage/lun3
    Created block storage object lun3 using /dev/zvol/zpool_lun_storage/lun3.
    /backstores/block> create name=lun4 dev=/dev/zvol/zpool_lun_storage/lun4
    Created block storage object lun4 using /dev/zvol/zpool_lun_storage/lun4.
    /backstores/block> cd /iscsi
    /iscsi> create
    Created target iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0.
    Created TPG 1.
    Global pref auto_add_default_portal=true
    Created default portal listening on all IPs (0.0.0.0), port 3260.
    /iscsi> ls
    o- iscsi .............................................................................................................. [Targets: 1]
      o- iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0 ............................................................ [TPGs: 1]
        o- tpg1 ................................................................................................. [no-gen-acls, no-auth]
          o- acls ............................................................................................................ [ACLs: 0]
          o- luns ............................................................................................................ [LUNs: 0]
          o- portals ...................................................................................................... [Portals: 1]
            o- 0.0.0.0:3260 ....................................................................................................... [OK]
    /iscsi> cd iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0
    /iscsi/iqn.20....ab22dc6d6dc0> cd tpg1/luns
    /iscsi/iqn.20...dc0/tpg1/luns> create /backstores/block/lun0
    Created LUN 0.
    /iscsi/iqn.20...dc0/tpg1/luns> create /backstores/block/lun1
    Created LUN 1.
    /iscsi/iqn.20...dc0/tpg1/luns> create /backstores/block/lun2
    Created LUN 2.
    /iscsi/iqn.20...dc0/tpg1/luns> create /backstores/block/lun3
    Created LUN 3.
    /iscsi/iqn.20...dc0/tpg1/luns> create /backstores/block/lun4
    Created LUN 4.
    /iscsi/iqn.20...dc0/tpg1/luns> cd ..
    /iscsi/iqn.20...dc6d6dc0/tpg1> cd acls
    /iscsi/iqn.20...dc0/tpg1/acls> create iqn.1988-12.com.oracle:58e84cb3eaf6
    Created Node ACL for iqn.1988-12.com.oracle:58e84cb3eaf6
    Created mapped LUN 4.
    Created mapped LUN 3.
    Created mapped LUN 2.
    Created mapped LUN 1.
    Created mapped LUN 0.
    /iscsi/iqn.20...dc0/tpg1/acls> create iqn.1988-12.com.oracle:e647892de987
    Created Node ACL for iqn.1988-12.com.oracle:e647892de987
    Created mapped LUN 4.
    Created mapped LUN 3.
    Created mapped LUN 2.
    Created mapped LUN 1.
    Created mapped LUN 0.
    /> cd /
    /> saveconfig
    Global pref auto_save_on_exit=true
    Configuration saved to /etc/target/saveconfig.json
    /> exit

###### OPEN ON FIREWALL ISCSI COMMUNICATION

    [root@exated ~]# firewall-cmd --zone=public --add-port=3260/tcp --permanent
    [root@exated ~]# firewall-cmd --reload

###### writed by: Grok (adapted from Danilo Arruda’s LVM guide)
###### qua 28 mai 2025% 
