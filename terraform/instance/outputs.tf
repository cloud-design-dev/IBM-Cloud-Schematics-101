output "primary_network_interface_id" {
  value = ibm_is_instance.instance.primary_network_interface[0].id
}

output "primary_ipv4_address" {
  value = ibm_is_instance.instance.primary_network_interface[0].primary_ipv4_address
}

output "instance" {
  value = ibm_is_instance.instance
}

output "id" {
  value = ibm_is_instance.instance.id
}
