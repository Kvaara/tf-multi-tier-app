resource "oci_load_balancer_load_balancer" "this" {
  #Required
  compartment_id = var.tenancy_ocid
  display_name   = "${var.namespace}-lb"
  shape          = "flexible"
  subnet_ids     = [oci_core_subnet.public.id]

  is_private                 = false
  network_security_group_ids = [oci_core_network_security_group.for_lb.id]
  shape_details {
    maximum_bandwidth_in_mbps = 10
    minimum_bandwidth_in_mbps = 10
  }
}

resource "oci_load_balancer_listener" "this" {
  default_backend_set_name = oci_load_balancer_backend_set.this.name
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = "${var.namespace}-lb-listener"
  port                     = 80
  protocol                 = "HTTP"

  #   hostname_names      = [oci_load_balancer_hostname.test_hostname.name]
  #   path_route_set_name = oci_load_balancer_path_route_set.test_path_route_set.name
  #   routing_policy_name = oci_load_balancer_load_balancer_routing_policy.test_load_balancer_routing_policy.name
  #   rule_set_names      = [oci_load_balancer_rule_set.test_rule_set.name]
}

resource "oci_load_balancer_backend_set" "this" {
  #Required
  health_checker {
    protocol = "HTTP"

    port = 8080
    # response_body_regex = var.backend_set_health_checker_response_body_regex
    # return_code         = var.backend_set_health_checker_return_code
    # url_path            = var.backend_set_health_checker_url_path
  }
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = "${var.namespace}-lb-backend-set"
  policy           = "ROUND_ROBIN"
}

resource "oci_load_balancer_backend" "this" {
  backendset_name  = oci_load_balancer_backend_set.this.name
  ip_address       = oci_core_instance.this.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  port             = 8080

  #Optional
  #   backup          = var.backend_backup
  #   drain           = var.backend_drain
  #   max_connections = var.backend_max_connections
  #   offline         = var.backend_offline
  #   weight          = var.backend_weight
}
