### ORACLE DATABASE 23ai SI FS ONE CDB SILENT MODE OL9

#### BUILD VIRTUAL MACHINE
    virt-install --virt-type kvm --name ol9 --memory 2048 --vcpus 2 --os-variant ol9.5 --cdrom /root/Downloads/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9.qcow2,size=50

#### CONFIGURE HOSTNAME
    hostnamectl set-hostname ol923ai

#### INSTALL PRE-INSTALL PACKAGES
    [root@ol923ai ~]# yum install oracle-database-preinstall-23ai
