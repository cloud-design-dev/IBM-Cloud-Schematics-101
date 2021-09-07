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

data "template_file" "init" {
  template = file("${path.module}/query.tmpl")
  vars = {
    workspace = lookup(data.external.env.result, "TF_VAR_IC_SCHEMATICS_WORKSPACE_ID", "")
  }
}
