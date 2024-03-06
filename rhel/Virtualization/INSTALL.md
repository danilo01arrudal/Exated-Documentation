### Notes 

To set up a KVM hypervisor and create virtual machines (VMs) on an AMD64 or Intel 64 system running RHEL 9, 
follow the instructions below. 
**This document focuses on Intel System 64 running RHEL 9c**

### Prerequisites 

Red Hat Enterprise Linux 9 is installed and registered on your host machine.
Your system meets the following hardware requirements to work as a virtualization host:
The architecture of your host machine supports KVM virtualization.
The following minimum system resources are available:
 6 GB free disk space for the host, plus another 6 GB for each intended VM.
 2 GB of RAM for the host, plus another 2 GB for each intended VM. 

### Procedure 
###### Install the virtualization hypervisor packages 
        dnf install -y qemu-kvm libvirt virt-install virt-viewer

###### Start the virtualization services: 
        for drv in qemu network nodedev nwfilter secret storage interface; do systemctl start virt${drv}d{,-ro,-admin}.socket; done

### Verification
###### Verify that your system is prepared to be a virtualization host: 
        virt-host-validate
        
###### Enabling IOMMU Manually
For Intel, boot the machine, and append intel_iommu=on to the end of the GRUB_CMDLINE_LINUX line in the grub configuration file. 

        vi /etc/default/grub
        ...
        GRUB_CMDLINE_LINUX="nofb splash=quiet console=tty0 ... intel_iommu=on
        ...

###### Refresh the grub.cfg file and reboot the host for these changes to take effect: 
        grubby --update-kernel=ALL --args="intel_iommu=on"
        reboot
        
###### Managing virtual machines in the web console
       https://$ip:9090


        
    
