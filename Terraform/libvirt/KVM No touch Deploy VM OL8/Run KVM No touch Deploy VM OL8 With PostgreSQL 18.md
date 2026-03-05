**Run KVM No touch Deploy VM OL8.10 With PostgreSQL18**


> *Terraform is a widely used open-source Infrastructure as Code (IaC) tool created by HashiCorp (now part of IBM) that enables developers and operations teams to define, provision, and manage infrastructure using declarative code.*
> *Terraform can manage libvirt virtualization resources through a third-party dmacvicar/libvirt provider. This integration allows users to use Infrastructure as Code (IaC) principles to define, deploy, and manage local virtual machines (VMs), networks, and storage pools, primarily on KVM/QEMU hypervisors.*

![terraform logo.](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Terraform/libvirt/images/terraform_logo.png)

###### THE PREREQUERIMENTS FOR THIS PROJECT ARE: 

    1 - Infrastructure provided by KVM
    2 - Configuration of a storage pool in libvirt
    3 - Configuration of a bridge interface
    4 - Availability of CPU/memory and disk resources
    5 - Configuration of a DNS server (bind)
        5.1 - This should resolve the virtual machine names specified in the Terraform parameter files, variables, and install_vm.sh
        [5.1 bind_VM_Configuration](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Bind/INSTALL%20AND%20CONFIGURE%20DNS%20SERVER%20ON%20OL9.md)

        

###### CLONE THE GIT REPOSITORY 

    [root@ ~]# git clone [https://github.com](https://github.com/danilo01arrudal/Exated-Documentation/tree/main/Terraform/libvirt/KVM%20No%20touch%20Deploy%20VM%20OL8)

###### RUN TERRAFORM INIT 

    [root@ terraform]# terraform init
      Initializing the backend...
      Initializing provider plugins...
      - Finding latest version of hashicorp/null...
      - Finding dmacvicar/libvirt versions matching "0.7.1"...
      - Installing hashicorp/null v3.2.4...
      - Installed hashicorp/null v3.2.4 (signed by HashiCorp)
      - Installing dmacvicar/libvirt v0.7.1...
      - Installed dmacvicar/libvirt v0.7.1 (self-signed, key ID 96B1FE1A8D4E1EAB)
      Partner and community providers are signed by their developers.
      If you'd like to know more about provider signing, you can read about it here:
      https://developer.hashicorp.com/terraform/cli/plugins/signing
      Terraform has created a lock file .terraform.lock.hcl to record the provider
      selections it made above. Include this file in your version control repository
      so that Terraform can guarantee to make the same selections by default when
      you run "terraform init" in the future.

      Terraform has been successfully initialized!

      You may now begin working with Terraform. Try running "terraform plan" to see
      any changes that are required for your infrastructure. All Terraform commands
      should now work.

      If you ever set or change modules or backend configuration for Terraform,
      rerun this command to reinitialize your working directory. If you forget, other
      commands will detect it and remind you to do so if necessary.

###### RUN TERRAFORM VALIDATE 

    [root@ terraform]# terraform validate
      Success! The configuration is valid.
      
###### RUN TERRAFORM PLAN

    [root@ terraform]# terraform plan
      Plan: 3 to add, 0 to change, 0 to destroy.

      ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

      Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.

###### RUN TERRAFORM APPLY

    [root@ terraform]# ./install_vm.sh 
      ----------------------------------------------------------
      Starting Phase 1: OS Installation (Anaconda)
      ----------------------------------------------------------

      Plan: 3 to add, 0 to change, 0 to destroy.
      libvirt_cloudinit_disk.commoninit: Creating...
      libvirt_volume.ol8_disk: Creating...
      libvirt_volume.ol8_disk: Creation complete after 0s [id=/var/lib/libvirt/images/ol8pg18sh01.qcow2]
      libvirt_cloudinit_disk.commoninit: Creation complete after 0s [id=/var/lib/libvirt/images/commoninit.iso;80281ca3-500e-431d-829d-3de0df27a3e1]
      libvirt_domain.ol8_vm: Creating...
      libvirt_domain.ol8_vm: Creation complete after 1s [id=665c2ac1-65e6-4441-a823-bdc53e5be99b]
      Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
      Waiting for VM to power off (Installation in progress)...
      Still installing... 15:35:14
      Still installing... 15:35:29

      VM powered off. Installation complete.
      ----------------------------------------------------------
      Starting Phase 2: Adjusting boot and installing PostgreSQL
      ----------------------------------------------------------
      libvirt_volume.ol8_disk: Refreshing state... [id=/var/lib/libvirt/images/ol8pg18sh01.qcow2]
      libvirt_cloudinit_disk.commoninit: Refreshing state... [id=/var/lib/libvirt/images/commoninit.iso;80281ca3-500e-431d-829d-3de0df27a3e1]
      libvirt_domain.ol8_vm: Refreshing state... [id=665c2ac1-65e6-4441-a823-bdc53e5be99b]

      Apply complete! Resources: 2 added, 0 changed, 1 destroyed.
      Waiting for SSH to be ready on 192.168.18.51...
      SSH is up! Terraform will now run the remote-exec provisioner.
      Deployment finished successfully!

###### ACCESS THE VM ENVIRONMENT

    [root@ terraform]# ssh -i ~/.ssh/id_rsa_terraform root@192.168.18.51

###### ACCESS THE VM ENVIRONMENT
    
    [root@ol8pg18sh01 ~]# cat /etc/redhat-release 
    Red Hat Enterprise Linux release 8.10 (Ootpa)
