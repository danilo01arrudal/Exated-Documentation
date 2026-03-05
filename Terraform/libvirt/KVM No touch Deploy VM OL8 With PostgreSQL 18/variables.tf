# --- CONTROL VARIABLES ---
variable "install_os" {
  type        = bool
  default     = true
  description = "Set to true for Anaconda installation phase. Set to false for post-install HDD boot."
}

# --- INFRASTRUCTURE VARIABLES ---
variable "vm_name" {
  type    = string
  default = "ol8pg18sh01"
}

variable "vm_memory" {
  type    = string
  default = "10240"
}

variable "vm_vcpu" {
  type    = number
  default = 2
}

variable "disk_size" {
  type    = number
  default = 63350767616 # ~59GB
}

variable "iso_path" {
  type    = string
  default = "/var/lib/libvirt/images/OracleLinux-R8-U10-x86_64-dvd.iso"
}

# --- NETWORK VARIABLES ---
variable "ip_address" {
  type    = string
  default = "192.168.18.51"
}

variable "gateway" {
  type    = string
  default = "192.168.18.1"
}

variable "dns_server" {
  type    = string
  default = "192.168.18.43"
}

variable "hostname" {
  type    = string
  default = "ol8pg18sh01.appsdba.info"
}

variable "network_device" {
  type    = string
  default = "ens3" # Fixed device name to match KVM/QEMU detection
}

# --- SSH & ACCESS VARIABLES ---
variable "ssh_user" {
  type    = string
  default = "root"
}

variable "ssh_password" {
  type    = string
  default = "linux01"
}

# Public Key for SSH Access (Injected into Kickstart)
variable "ssh_public_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdp99IEcXK/8Zu7GaJXo+PXTRsdDwzlDBx/oEQWMG+VS52MSyEABANw2oSnu6y4Y3PQ44q+HZ0b02k2mF1Cc78eC8fJbfRXisXxvRAaBoaoL3lAyclM1fxdpd8F9AqPyRUkUxrcI67/P1qdrCDVF1z8sZxW31nxCMXypm2djqj9MUu1J7oCwVBiaGMFSerdkQkWD1QNxpHC5Ps8YKfsL8KrxBScsuyXNdfDC+S0rHUNNQKq9N+TQz7WI8YOzO8ysmPTp97/W0oYKeH2samQwaWriFuSU4MFAfi0CYVgS+fhyTYeik7VXsHQCmyhn1bMutgCx/h2t4Th0UZQhFbvpmGj1d/JgVoHfW+tXwsvg4wPRctk7ZFWQdJSTw/m1QamLNMbMWt7Yvt06tVNOVapj2m7jFBjP6Gyevk/xqWaNlDpztg/qgqP5YAD1TsdLy0dHw3ZYtSkQyndvO5yQ9xBmhOeShoXmEVNePJROZXsIkUkaspNeNAC+wcFVqJ7p8ouCjyCV5FiOKF3Xnyvy7WxM6l9oO5dysiTaWlGwNLX2G5Sfu8FV7JqqqULQ1fxseAEe+5oxGo9Lz2IYuI9v8LLA3EVxH5zFi8gLV3dgJzclMAoG//1JW5GVaOySaf7zzw2GxPDl1kq/QbtxcEmtiLTEPs6ZThZEh6uVHKlgIevFaUBw== root@Exated"
}

# Local path to the private key for Terraform connection
variable "ssh_private_key_path" {
  type    = string
  default = "~/.ssh/id_rsa_terraform"
}

# Hash generated for 'linux01' password (as fallback)
variable "root_pw_hash" {
  type    = string
  default = "$6$rounds=4096$vS7Z6.7F9.R.D8U/$fXpB9S9X1T9O6L7YV0O9F6G8Q9E6J8V0O9F6G8Q9E6J8V0O9F6G8Q9E6J8V0O9F6G8Q9E6J8V0O9F6G8Q9E6J8"
}
