EDB_Postgres_Advanced_Server_17

    [root@exated ~]# virt-install --virt-type kvm --name ol9pgedb --memory 4096 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9pgedb.qcow2,size=50
