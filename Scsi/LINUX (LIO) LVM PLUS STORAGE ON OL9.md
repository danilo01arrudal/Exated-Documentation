LINUX (LIO) LVM PLUS STORAGE ON OL9.5

> *Linux-IO Target (LIO) is an open-source Small Computer System Interface (SCSI) target implementation included in the Linux kernel.
In simple terms, LIO allows a Linux server to share its storage devices (such as hard drives) with other computers over a network.*

>    *(1) LIO turns a Linux server into a network storage server.*

>    *(2) It allows this server to expose storage devices as "targets" for other computers ("initiators") to access.*

![oracle linux iscsi logo.](https://github.com/danilo01arrudal/Exated/blob/main/Scsi/images/iSCSI.png)


> *LVM, or Logical Volume Manager, is a powerful tool in Linux that provides a flexible and efficient way to manage storage devices. Instead of partitioning physical disks directly, LVM creates an abstraction layer that allows you to manipulate storage logically.*

>    *Flexibility: Allows you to resize logical volumes without having to restart the system, which is ideal for dynamic environments.*

>    *Snapshots: Allows you to create snapshots of logical volumes, which are instantaneous copies that can be used for backups or testing.*

>    *Disk Concatenation: It is possible to combine multiple physical disks into a single Volume Group, increasing storage capacity.*

>    *Simplified management: Makes it easier to manage large amounts of storage, especially in servers and data centers.*

>    *Online Resizing: The ability to increase or decrease the size of Logical Volumes without having to dismount them.*

###### BUILD MACHINE

    [root@ol9scsi ~]# virt-install --virt-type kvm --name ol9scci --memory 8192 --vcpus 2 --os-variant ol9.7 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U7-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9scsi.qcow2,size=20 --disk path=/var/lib/libvirt/images/ol9scsi-data01.qcow2,size=160

###### INSTALL LVM2

    [root@ol9scsi ~]# yum install -y lvm2

###### CONFIGURE DEVICES

    [root@ol9scsi ~]# fdisk -l
    Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
    Disk model: QEMU HARDDISK   
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x60411e4d

    Device     Boot    Start      End  Sectors Size Id Type
    /dev/sda1           2048 39845887 39843840  19G 8e Linux LVM
    /dev/sda2  *    39845888 41943039  2097152   1G 83 Linux

    Disk /dev/sdb: 160 GiB, 171798691840 bytes, 335544320 sectors
    Disk model: QEMU HARDDISK   
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes

    [root@ol9scsi ~]# fdisk /dev/sdb 
    n > p > 1 > w

###### CONFIGURE LVM 

    [root@ol9scsi ~]# pvcreate /dev/nvme0n1p1
    [root@ol9scsi ~]# pvcreate /dev/nvme1n1p1
    [root@ol9scsi ~]# vgcreate vg_lun_storage /dev/nvme0n1p1 /dev/nvme1n1p1 
    [root@ol9scsi ~]# lvcreate -n lv_lun_storage_l0 -L 20G vg_lun_storage
    [root@ol9scsi ~]# lvcreate -n lv_lun_storage_l1 -L 20G vg_lun_storage
    [root@ol9scsi ~]# lvcreate -n lv_lun_storage_l2 -L 20G vg_lun_storage
    [root@ol9scsi ~]# lvcreate -n lv_lun_storage_l3 -L 20G vg_lun_storage
    [root@ol9scsi ~]# lvcreate -n lv_lun_storage_l4 -L 20G vg_lun_storage  
    [root@ol9scsi ~]# lvs
    LV                VG             Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert                                                  
    lv_lun_storage_l0 vg_lun_storage -wi-a----- 20,00g                                                    
    lv_lun_storage_l1 vg_lun_storage -wi-a----- 20,00g                                                    
    lv_lun_storage_l2 vg_lun_storage -wi-a----- 20,00g                                                    
    lv_lun_storage_l3 vg_lun_storage -wi-a----- 20,00g                                                    
    lv_lun_storage_l4 vg_lun_storage -wi-a----- 20,00g


> *targetcli is a command-line interface (CLI) for configuring the Linux Target Subsystem (LIO), which allows a Linux server to expose storage devices as iSCSI, Fibre Channel, or other network storage protocol targets.*

>    *Creating iSCSI Targets: Allows you to configure and manage iSCSI targets, which are networked storage devices that can be accessed by other servers (iSCSI initiators) over an IP network.*

>    *Managing other storage protocols: In addition to iSCSI, targetcli also supports other network storage protocols such as Fibre Channel (FC) and Fibre Channel over Ethernet (FCoE).*

>    *Configuring LUNs (Logical Unit Numbers): Allows you to create and manage LUNs, which are logical representations of storage devices that are exposed to initiators.*

>    *Access Control: Allows you to configure access control for your storage targets by defining which initiators can access which LUNs.*

>    *Snapshot and clone management: In conjunction with other software, targetcli can be used to manage snapshots and clones of storage devices.*

###### INSTALL AND CONFIGURE TARGETCLI

    [root@ol9scsi ~]# yum install -y targetcli

    [root@ol9scsi ~]# systemctl start target.service
    [root@ol9scsi ~]# systemctl enable target.service

    [root@ol9scsi ~]# targetcli
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
    /backstores/block> create name=lun0 dev=/dev/vg_lun_storage/lv_lun_storage_l0 
    Created block storage object lun0 using /dev/vg_lun_storage/lv_lun_storage_l0.
    /backstores/block> create name=lun1 dev=/dev/vg_lun_storage/lv_lun_storage_l1 
    Created block storage object lun1 using /dev/vg_lun_storage/lv_lun_storage_l1.
    /backstores/block> create name=lun2 dev=/dev/vg_lun_storage/lv_lun_storage_l2 
    Created block storage object lun2 using /dev/vg_lun_storage/lv_lun_storage_l2.
    /backstores/block> create name=lun3 dev=/dev/vg_lun_storage/lv_lun_storage_l3 
    Created block storage object lun3 using /dev/vg_lun_storage/lv_lun_storage_l3.
    /backstores/block> create name=lun4 dev=/dev/vg_lun_storage/lv_lun_storage_l4 
    Created block storage object lun4 using /dev/vg_lun_storage/lv_lun_storage_l4.
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
    /> ls
    o- / ......................................................................................................................... [...]
      o- backstores .............................................................................................................. [...]
      | o- block .................................................................................................. [Storage Objects: 5]
      | | o- lun0 ............................................... [/dev/vg_lun_storage/lv_lun_storage_l0 (20.0GiB) write-thru activated]
      | | | o- alua ................................................................................................... [ALUA Groups: 1]
      | | |   o- default_tg_pt_gp ....................................................................... [ALUA state: Active/optimized]
      | | o- lun1 ............................................... [/dev/vg_lun_storage/lv_lun_storage_l1 (20.0GiB) write-thru activated]
      | | | o- alua ................................................................................................... [ALUA Groups: 1]
      | | |   o- default_tg_pt_gp ....................................................................... [ALUA state: Active/optimized]
      | | o- lun2 ............................................... [/dev/vg_lun_storage/lv_lun_storage_l2 (20.0GiB) write-thru activated]
      | | | o- alua ................................................................................................... [ALUA Groups: 1]
      | | |   o- default_tg_pt_gp ....................................................................... [ALUA state: Active/optimized]
      | | o- lun3 ............................................... [/dev/vg_lun_storage/lv_lun_storage_l3 (20.0GiB) write-thru activated]
      | | | o- alua ................................................................................................... [ALUA Groups: 1]
      | | |   o- default_tg_pt_gp ....................................................................... [ALUA state: Active/optimized]
      | | o- lun4 ............................................... [/dev/vg_lun_storage/lv_lun_storage_l4 (20.0GiB) write-thru activated]
      | |   o- alua ................................................................................................... [ALUA Groups: 1]
      | |     o- default_tg_pt_gp ....................................................................... [ALUA state: Active/optimized]
      | o- fileio ................................................................................................. [Storage Objects: 0]
      | o- pscsi .................................................................................................. [Storage Objects: 0]
      | o- ramdisk ................................................................................................ [Storage Objects: 0]
      o- iscsi ............................................................................................................ [Targets: 1]
      | o- iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0 .......................................................... [TPGs: 1]
      |   o- tpg1 ............................................................................................... [no-gen-acls, no-auth]
      |     o- acls .......................................................................................................... [ACLs: 2]
      |     | o- iqn.1988-12.com.oracle:58e84cb3eaf6 .................................................................. [Mapped LUNs: 5]
      |     | | o- mapped_lun0 .................................................................................. [lun0 block/lun0 (rw)]
      |     | | o- mapped_lun1 .................................................................................. [lun1 block/lun1 (rw)]
      |     | | o- mapped_lun2 .................................................................................. [lun2 block/lun2 (rw)]
      |     | | o- mapped_lun3 .................................................................................. [lun3 block/lun3 (rw)]
      |     | | o- mapped_lun4 .................................................................................. [lun4 block/lun4 (rw)]
      |     | o- iqn.1988-12.com.oracle:e647892de987 .................................................................. [Mapped LUNs: 5]
      |     |   o- mapped_lun0 .................................................................................. [lun0 block/lun0 (rw)]
      |     |   o- mapped_lun1 .................................................................................. [lun1 block/lun1 (rw)]
      |     |   o- mapped_lun2 .................................................................................. [lun2 block/lun2 (rw)]
      |     |   o- mapped_lun3 .................................................................................. [lun3 block/lun3 (rw)]
      |     |   o- mapped_lun4 .................................................................................. [lun4 block/lun4 (rw)]
      |     o- luns .......................................................................................................... [LUNs: 5]
      |     | o- lun0 .......................................... [block/lun0 (/dev/vg_lun_storage/lv_lun_storage_l0) (default_tg_pt_gp)]
      |     | o- lun1 .......................................... [block/lun1 (/dev/vg_lun_storage/lv_lun_storage_l1) (default_tg_pt_gp)]
      |     | o- lun2 .......................................... [block/lun2 (/dev/vg_lun_storage/lv_lun_storage_l2) (default_tg_pt_gp)]
      |     | o- lun3 .......................................... [block/lun3 (/dev/vg_lun_storage/lv_lun_storage_l3) (default_tg_pt_gp)]
      |     | o- lun4 .......................................... [block/lun4 (/dev/vg_lun_storage/lv_lun_storage_l4) (default_tg_pt_gp)]
      |     o- portals .................................................................................................... [Portals: 1]
      |       o- 0.0.0.0:3260 ..................................................................................................... [OK]
      o- loopback ......................................................................................................... [Targets: 0]
      o- vhost ............................................................................................................ [Targets: 0]
    /> exit
    Global pref auto_save_on_exit=true
    Configuration saved to /etc/target/saveconfig.json

###### OPEN ON FIREWALL ISCSI COMMUNICATION

    [root@ol9scsi ~]# firewall-cmd --zone=public --add-port=3260/tcp --permanent
    [root@ol9scsi ~]# firewall-cmd --reload

###### DESTROY ISCSI CONFIGURATION

    /iscsi/iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0/tpg1/acls delete iqn.1994-05.com.redhat:2868b8b62d
    /iscsi/iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0/tpg1/acls delete iqn.1994-05.com.redhat:afaace60edb7
    /iscsi/iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0/tpg1/luns delete LUN_1
    /iscsi/iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0/tpg1/luns delete LUN_2
    /iscsi/iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0/tpg1/luns delete LUN_3
    /iscsi/iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0/tpg1/luns delete LUN_4
    /iscsi delete iqn.2003-01.org.linux-iscsi.exated.x8664:sn.ab22dc6d6dc0
    /backstores/block delete LUN_1
    /backstores/block delete LUN_2
    /backstores/block delete LUN_3
    /backstores/block delete LUN_4
    ls

###### writed by: Danilo Arruda
###### ter 23 fev 2025





