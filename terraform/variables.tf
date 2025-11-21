
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "datacenter" {}
variable "cluster" {}
variable "datastore" {}
variable "network" {}
variable "template_name" {}
variable "disk_size" {
  description = "Disk size in GB"
  default     = 10
}
