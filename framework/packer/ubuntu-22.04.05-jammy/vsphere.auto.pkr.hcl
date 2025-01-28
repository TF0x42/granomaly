packer {
  required_plugins {
    vsphere = {
      version = ">= 1.2.4"
      source = "github.com/hashicorp/vsphere"
    }
  }
}

variable "vsphere_datastore" {
  type    = string
  default = ""
}

variable "vsphere_datacenter" {
  type    = string
  default = ""
}

variable "vsphere_host" {
  type    = string
  default = ""
}

variable "vsphere_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "vsphere_network" {
  type    = string
  default = ""
}

variable "vsphere_server" {
  type    = string
  default = ""
}

variable "vsphere_folder" {
  type    = string
  default = "Templates"
}

variable "vsphere_username" {
  type    = string
  default = ""
}

variable "vsphere_insecure_connection" {
  type    = string
  default = "false"
}

variable "ssh_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "ssh_username" {
  type    = string
  default = ""
}


source "vsphere-iso" "ubuntu" {

  vcenter_server        = var.vsphere_server
  host                  = var.vsphere_host
  username              = var.vsphere_username
  password              = var.vsphere_password
  insecure_connection   = var.vsphere_insecure_connection
  datacenter            = var.vsphere_datacenter
  datastore             = var.vsphere_datastore
  folder                = var.vsphere_folder

  CPUs                  = 2
  RAM                   = 4096
  RAM_reserve_all       = false
  disk_controller_type  = ["pvscsi"]
  guest_os_type         = "ubuntu64Guest"
  iso_paths             = ["[ISOs] ubuntu-22.04.5-live-server-amd64.iso"]
  cd_content            = {
    "/meta-data" = file("./http/meta-data")
    "/user-data" = file("./http/user-data")
  }
  cd_label              = "cidata"
  reattach_cdroms       = 1
  cdrom_type            = "sata"

  network_adapters {
    network             = var.vsphere_network
    network_card        = "vmxnet3"
  }

  storage {
    disk_size             = 11200
    disk_thin_provisioned = true
  }

  vm_name               = "template-ubuntu-22-04-5"
  notes                 = "Template created ${formatdate("YYYY-MM-DD", timestamp())}"
  convert_to_template   = "true"
  communicator          = "ssh"
  ssh_username          = var.ssh_username
  ssh_password          = var.ssh_password
  ssh_timeout           = "30m"
  ssh_handshake_attempts = "100000"

  boot_order            = "disk,cdrom,floppy"
  boot_wait             = "3s"
  boot_command          = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net\"",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
    ]
  shutdown_command      = "echo '${var.ssh_password}' | sudo -S -E shutdown -P now"
  shutdown_timeout      = "15m"

  configuration_parameters = {
    "disk.EnableUUID" = "true"
  }
}

build {
  sources = ["source.vsphere-iso.ubuntu"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    environment_vars = [
      "BUILD_USERNAME=${var.ssh_username}",
    ]
    scripts = ["./setup/setup.sh"]
    expect_disconnect = true
  }
}
