resource "ibm_is_lb" "consul" {
  name           = "${var.name}-loadbalancer"
  subnets        = [var.subnet]
  profile        = "network-fixed"
  resource_group = var.resource_group
  tags           = concat(var.tags)
}

resource "ibm_is_lb_listener" "consul" {
  lb       = ibm_is_lb.consul.id
  port     = "8500"
  protocol = "tcp"
}


resource "ibm_is_lb_pool" "consul" {
  depends_on               = [ibm_is_lb_listener.consul]
  name                     = "${var.name}-pool"
  lb                       = ibm_is_lb.consul.id
  algorithm                = "round_robin"
  protocol                 = "tcp"
  health_delay             = 60
  health_retries           = 5
  health_timeout           = 30
  health_type              = "tcp"
  health_monitor_port      = "8500"
  proxy_protocol           = "v1"
  session_persistence_type = "source_ip"
}

resource "ibm_is_lb_pool_member" "consul" {
  depends_on     = [ibm_is_lb_listener.consul]
  count          = length(var.instances)
  lb             = ibm_is_lb.consul.id
  pool           = element(split("/", ibm_is_lb_pool.consul.id), 1)
  port           = 8500
  target_address = var.ips[count.index]
  weight         = 60
}