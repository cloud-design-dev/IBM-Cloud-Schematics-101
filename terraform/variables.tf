variable "name" {
  type        = string
  description = ""
  default     = ""
}

variable "resource_group" {
  type        = string
  description = ""
  default     = ""
}

variable "region" {
  type        = string
  description = ""
  default     = ""
}


variable "instance_count" {
  type        = number
  description = ""
  default     = 1
}

variable "ssh_key" {
  type        = string
  description = "Name of an existing SSH key that will be added to the compute instances."
  default     = ""
}

variable "allow_ssh_from" {
  type        = string
  description = "An IP address, a CIDR block, or a single security group identifier to allow incoming SSH connection to the bastion."
  default     = ""
}

variable "create_public_ip" {
  type        = bool
  description = "Set whether to allocate a public IP address for the bastion instance. Default is `true`."
  default     = true
}

variable "tags" {
  type        = list(string)
  description = ""
  default     = ["owner:ryantiffany"]
}

variable "cos_instance" {
  default = "ibmcos-rt"
}

variable "bucket_name" {
  default = "schematics-output-for-setting-up-code-engine"
}

variable "special_tag" {
  default = "lab-inventory"
}