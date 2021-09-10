data "ibm_is_ssh_key" "deployment_key" {
  name = var.ssh_key
}

data "ibm_resource_group" "project" {
  name = var.resource_group
}

data "ibm_is_zones" "region" {
  region = var.region
}

data "external" "env" {
  program = ["jq", "-n", "env"]
}

data "ibm_resource_instance" "cos_instance" {
  name              = var.cos_instance
  resource_group_id = data.ibm_resource_group.project.id
  service           = "cloud-object-storage"
}

data "ibm_cos_bucket" "schematics_output" {
  bucket_name          = var.bucket_name
  resource_instance_id = data.ibm_resource_instance.cos_instance.id
  bucket_type          = "region_location"
  bucket_region        = "us-south"
}

# data "template_file" "init" {
#   template = file("${path.module}/query.tmpl")
#   vars = {
#     workspace = lookup(data.external.env.result, "TF_VAR_IC_SCHEMATICS_WORKSPACE_ID", "")
#   }
# }
