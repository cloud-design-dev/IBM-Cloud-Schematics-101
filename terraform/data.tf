data "ibm_is_ssh_key" "deployment_key" {
  name = "hyperion-${var.region}"
}

data "ibm_resource_group" "project" {
  name = var.resource_group
}

data "ibm_is_zones" "region" {
  region = var.region
}
