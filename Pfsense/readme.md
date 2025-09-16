virt-install --virt-type kvm --name pfSense272 --memory 2048 --vcpus 2 --osinfo detect=on,require=off --os-type unix --cdrom /var/lib/libvirt/images/pfSense-CE-2.7.2-RELEASE-amd64.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/pfSense272.qcow2,size=20

192.168.18.220

passwd root


