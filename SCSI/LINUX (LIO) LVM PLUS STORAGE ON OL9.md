LINUX (LIO) LVM PLUS STORAGE ON OL9.5

> *Linux-IO Target (LIO) is an open-source Small Computer System Interface (SCSI) target implementation included in the Linux kernel.
In simple terms, LIO allows a Linux server to share its storage devices (such as hard drives) with other computers over a network.*

>    *(1) LIO turns a Linux server into a network storage server.*

>    *(2) It allows this server to expose storage devices as "targets" for other computers ("initiators") to access.*

![oracle linux iscsi logo.](https://github.com/danilo01arrudal/Exated/blob/main/SCSI/images/iSCSI.png)


> *LVM, or Logical Volume Manager, is a powerful tool in Linux that provides a flexible and efficient way to manage storage devices. Instead of partitioning physical disks directly, LVM creates an abstraction layer that allows you to manipulate storage logically.*

>    *Flexibility: Allows you to resize logical volumes without having to restart the system, which is ideal for dynamic environments.*

>    *Snapshots: Allows you to create snapshots of logical volumes, which are instantaneous copies that can be used for backups or testing.*

>    *Disk Concatenation: It is possible to combine multiple physical disks into a single Volume Group, increasing storage capacity.*

>    *Simplified management: Makes it easier to manage large amounts of storage, especially in servers and data centers.*

>    *Online Resizing: The ability to increase or decrease the size of Logical Volumes without having to dismount them.*

###### INSTALL LVM2

    [root@exated ~]# yum install -y lvm2

###### CONFIGURE DEVICES

    [root@exated ~]# fdisk -l    
    Disco /dev/nvme1n1: 931,51 GiB, 1000204886016 bytes, 1953525168 setores
    Modelo de disco: KINGSTON SA2000M81000G                  
    Unidades: setor de 1 * 512 = 512 bytes
    Tamanho de setor (lógico/físico): 512 bytes / 512 bytes
    Tamanho E/S (mínimo/ótimo): 512 bytes / 512 bytes
    Tipo de rótulo do disco: gpt
    Identificador do disco: E1A6E5FF-EF06-4B50-B3EF-7B192F6A3ADE

    Disco /dev/nvme0n1: 931,51 GiB, 1000204886016 bytes, 1953525168 setores
    Modelo de disco: KINGSTON SA2000M81000G                  
    Unidades: setor de 1 * 512 = 512 bytes
    Tamanho de setor (lógico/físico): 512 bytes / 512 bytes
    Tamanho E/S (mínimo/ótimo): 512 bytes / 512 bytes
    Tipo de rótulo do disco: gpt
    Identificador do disco: 0DED2B1E-DF36-45EB-B5AA-1DB6D15C9B3E

    [root@exated ~]# fdisk /dev/nvme0n1
    n > p > 1 > w
    [root@exated ~]# fdisk /dev/nvme1n1
    n > p > 1 > w

###### CONFIGURE LVM 

    [root@exated ~]# pvcreate /dev/nvme0n1p1
    [root@exated ~]# pvcreate /dev/nvme1n1p1
    [root@exated ~]# vgcreate vg_lun_storage /dev/nvme0n1p1 /dev/nvme1n1p1 
    [root@exated ~]# lvcreate -n lv_lun_storage_l0 -L 20G vg_lun_storage
    [root@exated ~]# lvcreate -n lv_lun_storage_l1 -L 20G vg_lun_storage
    [root@exated ~]# lvcreate -n lv_lun_storage_l2 -L 20G vg_lun_storage
    [root@exated ~]# lvcreate -n lv_lun_storage_l3 -L 20G vg_lun_storage
    [root@exated ~]# lvcreate -n lv_lun_storage_l4 -L 20G vg_lun_storage  
    [root@exated ~]# lvs
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


