variable "security_groups" {}
variable "image_name" {
  default = "ibm-ubuntu-20-04-2-minimal-amd64-1"
}


variable "subnet" {
  description = "Subnet ID to use for primary network interfaces."
}

variable "name" {
  type        = string
  description = "Name to attach to all resources."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to use for the compoute instance."
}

variable "resource_group_id" {
  type        = string
  description = "Resource Group ID to use for primary network interfaces."
}

variable "ssh_keys" {
  description = "SSH Key ID that will be inserted in to the compute instance."
}

variable "profile_name" {
  default = "cx2-2x4"
}

variable "tags" {}
variable "zone" {}
variable "user_data" {}
variable "allow_ip_spoofing" {
  type        = bool
  description = "(Optional, bool) Indicates whether IP spoofing is allowed on this interface."
  default     = false
}

variable "force_recovery_time" {
  type        = string
  description = "Timeout (in minutes), to force the is_instance to recover from a perpetual `starting` state."
  default     = "30"
}
