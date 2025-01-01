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
}

resource "oci_load_balancer_backend_set" "this" {
  health_checker {
    protocol    = "HTTP"
    port        = 8080
    return_code = 200
    url_path    = "/"
  }
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = "${var.namespace}-lb-backend-set"
  policy           = "ROUND_ROBIN"
}

resource "oci_load_balancer_backend" "this" {
  backendset_name  = oci_load_balancer_backend_set.this.name
  ip_address       = local.compute_instance_ip
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  port             = 8080
}
