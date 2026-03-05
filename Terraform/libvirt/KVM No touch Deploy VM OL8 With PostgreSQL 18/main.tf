terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system?socket=/var/run/libvirt/virtqemud-sock"
}

# 1. STORAGE: Create the 59GB QCOW2 Volume
resource "libvirt_volume" "ol8_disk" {
  name   = "${var.vm_name}.qcow2"
  pool   = "images"
  size   = var.disk_size
  format = "qcow2"
}

# 2. KICKSTART: Generate the ISO containing the user-data (Anaconda)
resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit_ol8pg18sh01.iso"
  pool      = "images"
  user_data = <<EOF
# Use poweroff instead of reboot to signal the script that installation is done
poweroff
text
cdrom
repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream

# Agree to EULA to prevent manual prompts
eula --agreed

%packages
# Use minimal environment to avoid GUI and overhead
@^minimal-environment
openssh-server
%end

keyboard --xlayouts='us'
lang en_US.UTF-8

# Network configuration for ens3
network --bootproto=static --device=${var.network_device} --gateway=${var.gateway} --ip=${var.ip_address} --nameserver=${var.dns_server} --netmask=255.255.255.0 --noipv6 --activate
network --hostname=${var.hostname}

firstboot --disable
ignoredisk --only-use=vda
clearpart --none --initlabel
part /boot --fstype="ext4" --ondisk=vda --size=1024
part pv.610 --fstype="lvmpv" --ondisk=vda --size=59391
volgroup ol_ol8pg18sh01 --pesize=4096 pv.610
logvol swap --fstype="swap" --size=10240 --name=swap --vgname=ol_ol8pg18sh01
logvol / --fstype="ext4" --size=49147 --name=root --vgname=ol_ol8pg18sh01
timezone America/Fortaleza --isUtc
rootpw --iscrypted ${var.root_pw_hash}

# Post-installation: Configure SSH for root access and inject Public Key
%post
# Configure SSHD
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config

# Inject Public Key for Root
mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "${var.ssh_public_key}" > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
restorecon -Rv /root/.ssh

systemctl enable sshd
%end
EOF
}

# 3. DOMAIN: VM Definition
resource "libvirt_domain" "ol8_vm" {
  name   = var.vm_name
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  boot_device {
    dev = ["hd", "cdrom"]
  }

  kernel  = var.install_os ? "/var/lib/libvirt/images/vmlinuz-ol8" : null
  initrd  = var.install_os ? "/var/lib/libvirt/images/initrd-ol8.img" : null
  
  cmdline = var.install_os ? [
    {
      "inst.ks"        = "hd:/dev/sr1:/user-data"
      "console"        = "ttyS0"
      "inst.graphical" = ""
      "ksdevice"       = var.network_device
    }
  ] : null

  disk {
    volume_id = libvirt_volume.ol8_disk.id
  }

  disk {
    file = var.iso_path
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    bridge = "br0"
  }

  network_interface {
    network_name = "priv0"
  }

  console {
    type        = "pty"
    target_port = "0"
  }

  graphics {
    type           = "vnc"
    listen_type    = "address"
    listen_address = "0.0.0.0" 
    autoport       = true
  }
}

# 4. PROVISIONING: PostgreSQL 18 Installation
resource "null_resource" "install_postgres" {
  depends_on = [libvirt_domain.ol8_vm]
  
  count = var.install_os ? 0 : 1

  connection {
    type        = "ssh"
    user        = var.ssh_user
    # Switched from password to private_key for better automation
    private_key = file(var.ssh_private_key_path)
    host        = var.ip_address
    agent       = false
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'SSH is up. Starting PostgreSQL 18 installation...'",
      "dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm",
      "dnf -qy module disable postgresql",
      "dnf install -y postgresql18-server",
      "dnf install -y postgresql18-contrib",
      "/usr/pgsql-18/bin/postgresql-18-setup initdb",
      "systemctl enable postgresql-18",
      "systemctl start postgresql-18",
      "echo 'PostgreSQL 18 is now installed and running.'"
    ]
  }
}
