output "vpc_id" {
  value = module.vpc.id
}

output "consul_instance_ip" {
  value = module.consul_cluster[*].primary_ipv4_address
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

# output "schematcs_environment" {
#   value = data.external.env.result
# }
