### ORACLE DATABASE 23ai SI FS ONE CDB SILENT MODE OL9.5

#### BUILD VIRTUAL MACHINE ON VIRTUALIZER
    [root@exated ~]# virt-install --virt-type kvm --name ol9 --memory 2048 --vcpus 2 --os-variant ol9.5 --cdrom /root/Downloads/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9.qcow2,size=50

#### CONFIGURE HOSTNAME
    [root@ ~]# hostnamectl set-hostname ol923ai

#### INSTALL PRE-INSTALL PACKAGES
    [root@ol923ai ~]# yum install oracle-database-preinstall-23ai

#### DISABLE SELINUX
    [root@ol923ai ~]# sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config && setenforce 0

#### CONFIGURE STATIC NETWORK
    [root@ol923ai ~]# nmcli device
    DEVICE  TYPE      STATE                   CONNECTION 
    enp1s0  ethernet  conectado               enp1s0     
    lo      loopback  connected (externally)  lo   

    [root@ol923ai ~]# nmcli connection show 
    NAME    UUID                                  TYPE      DEVICE 
    enp1s0  82e45657-ca14-380d-adfc-ac71a5aa7281  ethernet  enp1s0 
    lo      c30f3777-2d34-40f9-9fdb-da73383b9848  loopback  lo  

The background color is `#ffffff` for light mode and `#000000` for dark mode.
