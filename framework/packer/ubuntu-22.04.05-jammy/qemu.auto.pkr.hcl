packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
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

variable "host_arch" {
  description = "Die Architektur des Host-Systems"
  type        = string
  default     = ""
}

variable "qemu_binary" {
  description = "Der Pfad zum QEMU Binary, abhängig von der Host-Architektur"
  default     = ""
}

locals {
  accelerator = (
  #(local.arch == "x86_64") ? null :
    (var.host_arch == "arm64") ? "tcg" :
    null
  )
  display = (
  #(local.arch == "x86_64") ? null :
    (var.host_arch == "arm64") ? "cocoa" :
    null
  )
}

source "qemu" "ubuntu" {
  iso_url                = "https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum           = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
  net_device             = "virtio-net"
  disk_interface         = "virtio"
  disk_size              = "30G"
  communicator           = "ssh"
  ssh_username           = var.ssh_username
  ssh_password           = var.ssh_password
  ssh_timeout            = "30m"
  ssh_handshake_attempts = "100000"
  boot_wait              = "3s"
  boot_key_interval      = "50ms"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net\"",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  shutdown_command = "echo '${var.ssh_password}' | sudo -S -E shutdown -P now"
  shutdown_timeout = "15m"
  http_directory   = "http"
  memory           = 4096
  format           = "qcow2"
  display          = local.display
  accelerator      = local.accelerator
  vm_name          = "template-ubuntu-22-04-5.img"

}

build {
  sources = ["source.qemu.ubuntu"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    environment_vars = [
      "BUILD_USERNAME=${var.ssh_username}",
    ]
    scripts = ["./setup/setup.sh"]
    expect_disconnect = true
  }
}
