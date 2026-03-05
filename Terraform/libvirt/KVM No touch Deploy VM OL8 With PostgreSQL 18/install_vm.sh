#!/bin/bash

# Configuration - Matching your variables.tf
VM_NAME="ol8pg18sh01"
VM_IP="192.168.18.51"

echo "----------------------------------------------------------"
echo "Starting Phase 1: OS Installation (Anaconda)"
echo "----------------------------------------------------------"

# 1. Start the installation phase
terraform apply -var="install_os=true" -auto-approve

echo "Waiting for VM to power off (Installation in progress)..."

# 2. Monitor VM State
# It will exit the loop when the VM shuts down (due to 'poweroff' in Kickstart)
while [ "$(virsh domstate $VM_NAME 2>/dev/null)" == "running" ]; do
    sleep 15
    echo "Still installing... $(date +%H:%M:%S)"
done

echo "VM powered off. Installation complete."
echo "----------------------------------------------------------"
echo "Starting Phase 2: Adjusting boot and installing PostgreSQL"
echo "----------------------------------------------------------"

# 3. Clean up old SSH keys to avoid "Host Key Verification Failed"
# We do this right before the second boot
ssh-keygen -R $VM_IP 2>/dev/null

# 4. Update Terraform state to HDD boot
terraform apply -var="install_os=false" -auto-approve

# 5. Ensure the VM is started after the XML update
if [ "$(virsh domstate $VM_NAME)" != "running" ]; then
    echo "Starting VM for post-install provisioning..."
    virsh start $VM_NAME
fi

echo "Waiting for SSH to be ready on $VM_IP..."
# Wait until the port is open
while ! nc -z $VM_IP 22; do
  sleep 5
done

# Optional: Extra sleep to ensure SSHD is fully initialized after port opens
sleep 2

echo "SSH is up! Terraform will now run the remote-exec provisioner."
echo "Deployment finished successfully!"
