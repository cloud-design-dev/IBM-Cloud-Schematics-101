module "vpc" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Module.git"
  name           = "${var.name}-vpc}"
  resource_group = data.ibm_resource_group.project.id
  tags           = concat(var, tags, ["project:${var.name}", "region:${var.region}"])
}

module "public_gateway" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Public-Gateway-Module.git"
  name           = var.name
  zone           = var.zone
  vpc            = var.vpc
  resource_group = var.resource_group
  tags           = concat(var, tags, ["project:${var.name}", "region:${var.region}"])
}

module "bastion_subnet" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Subnet-Module.git"
  name           = var.name
  resource_group = var.resource_group
  network_acl    = var.network_acl
  address_count  = var.address_count
  vpc            = var.vpc_id
  zone           = var.zone
  public_gateway = var.public_gateway
  tags           = concat(var, tags, ["project:${var.name}", "region:${var.region}"])
}


module "consul_subnet" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Subnet-Module.git"
  name           = var.name
  resource_group = var.resource_group
  network_acl    = var.network_acl
  address_count  = var.address_count
  vpc            = var.vpc_id
  zone           = var.zone
  public_gateway = var.public_gateway
  tags           = concat(var, tags, ["project:${var.name}", "region:${var.region}"])
}

module "security" {

}

#
# A bastion to host OpenVPN
#
module "bastion" {
  source  = "we-work-in-the-cloud/vpc-bastion/ibm"
  version = "0.0.7"

  name              = "${var.name}-bastion"
  resource_group_id = local.resource_group_id
  vpc_id            = module.vpc.id
  subnet_id         = module.bastion_subnet.id
  ssh_key_ids       = local.ssh_key_ids
  tags              = concat(var, tags, ["project:${var.name}", "region:${var.region}"])
}


module "consul_cluster" {
  count           = var.instance_count
  source          = "./instance"
  vpc_id          = module.vpc.id
  subnets         = [module.bastion_subnet.id, module.consul_subnet.id]
  ssh_keys        = local.ssh_key_ids
  resource_group  = data.ibm_resource_group.project.id
  name            = "${var.name}-consul${count.index + 1}"
  zone            = data.ibm_is_zones.region.zones[0]
  security_groups = [module.security.consul_security_group, module.bastion.bastion_maintenance_group_id]
  tags            = concat(var.tags, ["project:${var.name}", "region:${var.region}", "zone:${data.ibm_is_zones.mzr.zones[0]}"])
  user_data       = file("${path.module}/install.yml")
}

# 