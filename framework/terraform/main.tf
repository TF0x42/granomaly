terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.2.0"
    }
  }
}

#Provider settings
provider "vsphere" {
  user 			= var.vsphere_user
  password		= var.vsphere_password
  vsphere_server	= var.vsphere_server
  allow_unverified_ssl	= false
}

locals {
  vms = {
    for i in range(1, var.num_vms + 1) : "6G-Host-${i}" => {
      name  = "6G-Host-${i}"
      vm_ip = "10.0.50.${i + 10}"
    }
  }
}


#Data sources

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "compute_cluster" {
  name			= var.vsphere_compute_cluster
  datacenter_id		= data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name			= var.vsphere_datastore
  datacenter_id         = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name			= var.vsphere_network
  datacenter_id		= data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name			= var.vm_template_name
  datacenter_id         = data.vsphere_datacenter.dc.id
}

#Resource

resource "vsphere_folder" "folder" {
  path          = var.vm_folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  for_each 		= local.vms

  folder = var.vm_folder
  datastore_id		= data.vsphere_datastore.datastore.id
  resource_pool_id	= data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  guest_id		= var.vm_guest_id

  network_interface {
    network_id 		= data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  name 			= each.value.name
  
  num_cpus 		= var.vm_vcpu
  memory		= var.vm_memory
#  firmware		= var.vm_firmware 
  disk {
    label		= var.vm_disk_label
    size		= var.vm_disk_size
    thin_provisioned	= var.vm_disk_thin
  }

  clone {
    template_uuid       = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name       = each.value.name
        domain		= var.vm_domain
    }
    network_interface {
      ipv4_address	= each.value.vm_ip
      ipv4_netmask	= var.vm_ipv4_netmask
    }
    dns_server_list	= var.vm_dns_servers
       ipv4_gateway     = var.vm_ipv4_gateway
   }
  }
 }


