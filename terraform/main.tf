module "vpc" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Module.git"
  name           = "${var.name}-vpc"
  resource_group = data.ibm_resource_group.project.id
  tags           = concat(var.tags, ["project:${var.name}", "region:${var.region}"])
}

module "public_gateway" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Public-Gateway-Module.git"
  name           = var.name
  zone           = data.ibm_is_zones.region.zones[0]
  vpc            = module.vpc.id
  resource_group = var.resource_group
  tags           = concat(var.tags, ["project:${var.name}", "region:${var.region}"])
}

module "subnet" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Subnet-Module.git"
  name           = "${var.name}-subnet"
  resource_group = data.ibm_resource_group.project.id
  network_acl    = module.vpc.default_network_acl
  address_count  = "32"
  vpc            = module.vpc.id
  zone           = data.ibm_is_zones.region.zones[0]
  public_gateway = module.public_gateway.id
  tags           = concat(var.tags, ["project:${var.name}", "region:${var.region}"])
}

module "security" {
  source         = "./security"
  vpc_id         = module.vpc.id
  name           = var.name
  resource_group = data.ibm_resource_group.project.id

}

#
# A bastion to host OpenVPN
#
module "bastion" {
  source  = "we-work-in-the-cloud/vpc-bastion/ibm"
  version = "0.0.7"

  name              = "${var.name}-bastion"
  resource_group_id = data.ibm_resource_group.project.id
  vpc_id            = module.vpc.id
  subnet_id         = module.subnet.id
  ssh_key_ids       = [data.ibm_is_ssh_key.deployment_key.id]
  allow_ssh_from    = var.allow_ssh_from
  create_public_ip  = var.create_public_ip
  init_script       = file("./instance/install.yml")
  tags              = concat(var.tags, ["project:${var.name}", "region:${var.region}", "zone:${data.ibm_is_zones.region.zones[0]}"])
}


module "consul_cluster" {
  depends_on        = [module.security]
  count             = var.instance_count
  source            = "./instance"
  vpc_id            = module.vpc.id
  subnet            = module.subnet.id
  ssh_keys          = [data.ibm_is_ssh_key.deployment_key.id]
  resource_group_id = data.ibm_resource_group.project.id
  name              = "${var.name}-consul${count.index + 1}"
  zone              = data.ibm_is_zones.region.zones[0]
  security_groups   = [module.security.consul_security_group, module.bastion.bastion_maintenance_group_id]
  tags              = concat(var.tags, ["project:${var.name}", "region:${var.region}", "zone:${data.ibm_is_zones.region.zones[0]}"])
  user_data         = file("./instance/install.yml")
}

