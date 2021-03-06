module "vpc" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Module.git"
  name           = "${var.name}-vpc"
  resource_group = data.ibm_resource_group.project.id
  tags           = concat(var.tags, ["project:${var.name}", "region:${var.region}"])
}

module "public_gateway" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Public-Gateway-Module.git"
  name           = "${var.name}-pub-gw"
  zone           = data.ibm_is_zones.region.zones[0]
  vpc            = module.vpc.id
  resource_group = data.ibm_resource_group.project.id
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
  tags              = concat(var.tags, ["project:${var.name}", "region:${var.region}", "zone:${data.ibm_is_zones.region.zones[0]}", var.special_tag])
  user_data         = file("./instance/install.yml")
}

#module "loadbalancer" {
#  source         = "./loadbalancer"
#  name           = var.name
#  resource_group = var.resource_group
#  ips            = module.consul_cluster[*].primary_ipv4_address
#  instances      = module.consul_cluster[*].id
#  subnet         = module.subnet.id
#  tags           = concat(var.tags, ["project:${var.name}", "region:${var.region}", "zone:${data.ibm_is_zones.region.zones[0]}"])
#}

resource "local_file" "schematic_json" {
  content  = jsonencode(data.external.env.result)
  filename = "${path.module}/schematics.json"
}




data "template_file" "init" {
  template = file("${path.module}/query.tmpl")
  vars = {
    workspace           = lookup(data.external.env.result, "TF_VAR_IC_SCHEMATICS_WORKSPACE_ID", "")
    iam_token           = lookup(data.external.env.result, "IC_IAM_TOKEN", "")
    resource_query_name = "${var.name}-resource-query"
    home                = lookup(data.external.env.result, "HOME", "")
    tag                 = var.special_tag
  }
}

resource "local_file" "query_script" {
  content  = data.template_file.init.rendered
  filename = "${path.module}/query.sh"
}



resource "null_resource" "generate_rq" {
  depends_on = [local_file.query_script]
  provisioner "local-exec" {
    command = "${path.module}/query.sh"
  }
}


resource "ibm_cos_bucket_object" "schematics_object" {
  bucket_crn      = data.ibm_cos_bucket.schematics_output.crn
  bucket_location = data.ibm_cos_bucket.schematics_output.region_location
  content_file    = "${path.module}/schematics.json"
  key             = "schematics.json"
}
