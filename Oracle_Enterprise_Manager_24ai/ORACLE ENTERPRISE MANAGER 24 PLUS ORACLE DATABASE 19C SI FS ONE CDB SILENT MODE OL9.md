**ORACLE ENTERPRISE MANAGER 24ai PLUS ORACLE DATABASE 19C SI FS ONE CDB SILENT MODE OL9.5**


> *Oracle Enterprise Manager 24ai is Oracle's modern management platform, enhanced with AI for managing Oracle Databases and Engineered Systems across on-premises and cloud. Key features include an AI-powered assistant, zero downtime monitoring and job system, highly available remote agents, container-based architecture, improved UI, and integration with OCI observability and AI services for enhanced insights, automation, and security.*

![oracle database 23ai logo.](https://github.com/danilo01arrudal/Documentation/blob/main/Oracle_Enterprise_Manager_24/images/images.png)

###### BUILD VIRTUAL MACHINE ON VIRTUALIZER
    
    [root@exated ~]# virt-install --virt-type kvm --name ol9d --memory 4096 --vcpus 2 --os-variant ol9.5 --cdrom /var/lib/libvirt/images/OracleLinux-R9-U5-x86_64-dvd.iso --network bridge=br0,model=virtio --disk path=/var/lib/libvirt/images/ol9d.qcow2,size=50
