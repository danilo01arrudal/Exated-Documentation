**Run KVM No touch Deploy VM OL8.10**


> *Terraform is a widely used open-source Infrastructure as Code (IaC) tool created by HashiCorp (now part of IBM) that enables developers and operations teams to define, provision, and manage infrastructure using declarative code.*
> *Terraform can manage libvirt virtualization resources through a third-party dmacvicar/libvirt provider. This integration allows users to use Infrastructure as Code (IaC) principles to define, deploy, and manage local virtual machines (VMs), networks, and storage pools, primarily on KVM/QEMU hypervisors.*

![terraform logo.](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Terraform/libvirt/images/terraform_logo.png)

###### CLONE THE GIT REPOSITORY 

    [root@ ~]# git clone [https://github.com](https://github.com/danilo01arrudal/Exated-Documentation/tree/main/Terraform/libvirt/KVM%20No%20touch%20Deploy%20VM%20OL8)

###### RUN TERRAFORM INIT 

    [root@ ~]# terraform init
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
