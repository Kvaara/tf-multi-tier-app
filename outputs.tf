output "url_where_application_is_listening_on" {
  value = "http://${oci_load_balancer_load_balancer.this.ip_address_details[0].ip_address}"
}
