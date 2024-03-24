### Notes 
  In this example i used raspberry pi to install and run terraform, but this step are universal for other linux and unix

### Prerequisites 
  It is recommended that the wget or curl package be available so that the terraform software can be downloaded.

### Procedure 
###### Download Terraform Software

      wget https://releases.hashicorp.com/terraform/0.14.9/terraform_0.14.9_linux_arm64.zip

###### List Terraform software file

      ls -ltr terraform_0.14.9_linux_arm64.zip 

###### Run a checksum in Terraform software file

      sha256sum terraform_0.14.9_linux_arm64.zip 

###### Unzip file

       unzip terraform_0.14.9_linux_arm64.zip     

###### Move the directory terraform to binaries directory of your Linux / Unix
      
      mv terraform /usr/local/bin/

###### Run Terraform install command

      terraform -install-autocomplete

###### Check if Terraform was correctly installed

      terraform -help






