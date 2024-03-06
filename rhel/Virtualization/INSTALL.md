#### Notes ####

    To set up a KVM hypervisor and create virtual machines (VMs) on an AMD64 or Intel 64 system running RHEL 9, 
    follow the instructions below. 
    *This document focuses on Intel System 64 running RHEL 9c*

#### Prerequisites ####

    Red Hat Enterprise Linux 9 is installed and registered on your host machine.
    Your system meets the following hardware requirements to work as a virtualization host:
    The architecture of your host machine supports KVM virtualization.
    The following minimum system resources are available:
       6 GB free disk space for the host, plus another 6 GB for each intended VM.
       2 GB of RAM for the host, plus another 2 GB for each intended VM. 

#### Procedure ####
    ## Install the virtualization hypervisor packages ##
        ``` diff 
        dnf install -y qemu-kvm libvirt virt-install virt-viewer
        ```
    ## 2. Start the virtualization services: 
        ``` diff 
        # for drv in qemu network nodedev nwfilter secret storage interface; do systemctl start virt${drv}d{,-ro,-admin}.socket; done
        ```
#### Verification ####
    ## 1. Verify that your system is prepared to be a virtualization host: 
        # virt-host-validate
          QEMU: Checking for hardware virtualization                                 : PASS
          QEMU: Checking if device /dev/kvm exists                                   : PASS
          QEMU: Checking if device /dev/kvm is accessible                            : PASS
          QEMU: Checking if device /dev/vhost-net exists                             : PASS
          QEMU: Checking if device /dev/net/tun exists                               : PASS
          QEMU: Checking for cgroup 'cpu' controller support                         : PASS
          QEMU: Checking for cgroup 'cpuacct' controller support                     : PASS
          QEMU: Checking for cgroup 'cpuset' controller support                      : PASS
          QEMU: Checking for cgroup 'memory' controller support                      : PASS
          QEMU: Checking for cgroup 'devices' controller support                     : PASS
          QEMU: Checking for cgroup 'blkio' controller support                       : PASS
          QEMU: Checking for device assignment IOMMU support                         : PASS
          QEMU: Checking if IOMMU is enabled by kernel                               : WARN (IOMMU appears to be disabled in kernel. Add intel_iommu=on to kernel cmdline arguments)
          QEMU: Checking for secure guest support                                    : WARN (Unknown if this platform has Secure Guest support)

  
    
