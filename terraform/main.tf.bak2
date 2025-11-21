terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.12.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

# -------------------------
# Data Sources
# -------------------------

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Network with UUID filter
data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
  distributed_virtual_switch_uuid = "50 22 da 27 09 bf 2d fe-97 42 a4 8d 3d 23 f9 73"
}

# Template with folder
data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
  folder        = "Templates"
}

# -------------------------
# Resource: Virtual Machine
# -------------------------

resource "vsphere_virtual_machine" "vm" {
  name             = "alel634"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "alel634"
        domain    = "main.ats.net"
      }

      network_interface {
        ipv4_address = "10.10.89.104"
        ipv4_netmask = 24
      }

      ipv4_gateway      = "10.10.89.254"
      dns_server_list   = ["10.10.79.1", "10.10.79.2"]
    }
  }
}
