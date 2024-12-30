resource "oci_core_vcn" "this" {
  compartment_id = var.tenancy_ocid

  cidr_blocks  = var.vcn_cidr_blocks // Private CIDR block based on RFC 1918. Reserves 14 IP addresses.
  display_name = "${var.namespace}-vcn"
}

resource "oci_core_subnet" "public" {
  cidr_block                 = cidrsubnet(oci_core_vcn.this.cidr_blocks[0], 1, 0) // 172.16.0.0 - 172.16.0.7
  compartment_id             = var.tenancy_ocid
  vcn_id                     = oci_core_vcn.this.id
  prohibit_public_ip_on_vnic = false
  display_name               = "${var.namespace}-subnet"
  #   route_table_id    = oci_core_route_table.test_route_table.id
  #   security_list_ids = var.subnet_security_list_ids
}

resource "oci_core_subnet" "private" {
  cidr_block                 = cidrsubnet(oci_core_vcn.this.cidr_blocks[0], 1, 1) // 172.16.0.8 - 172.16.0.15
  compartment_id             = var.tenancy_ocid
  vcn_id                     = oci_core_vcn.this.id
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.namespace}-subnet"
  #   route_table_id    = oci_core_route_table.test_route_table.id
  #   security_list_ids = var.subnet_security_list_ids
}

resource "oci_core_network_security_group" "for_lb" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.this.id

  display_name = "${var.namespace}-lb-nsg"
}

resource "oci_core_network_security_group_security_rule" "for_lb1" {
  network_security_group_id = oci_core_network_security_group.for_lb.id
  direction                 = "INGRESS"
  protocol                  = "6"

  description = "Allow HTTP traffic from outside to ${oci_load_balancer_load_balancer.this.display_name}"
  #   destination = var.network_security_group_security_rule_destination
  #   destination_type = var.network_security_group_security_rule_destination_type

  source      = "0.0.0.0/0" // Allows connections from any IPv4 address.
  source_type = "CIDR_BLOCK"
  tcp_options {

    destination_port_range {
      #Required
      max = 80
      min = 80
    }
    # source_port_range {
    #   #Required
    #   max = var.network_security_group_security_rule_tcp_options_source_port_range_max
    #   min = var.network_security_group_security_rule_tcp_options_source_port_range_min
    # }
  }
}

# resource "oci_core_network_security_group_security_rule" "for_lb2" {
#   network_security_group_id = oci_core_network_security_group.for_lb.id
#   direction                 = "INGRESS"
#   protocol                  = "6"

#   description = "Allow HTTP traffic from outside to ${oci_load_balancer_load_balancer.this.display_name}"
#   #   destination = var.network_security_group_security_rule_destination
#   #   destination_type = var.network_security_group_security_rule_destination_type

#   source      = "0.0.0.0/0" // Allows connections from any IPv4 address.
#   source_type = "CIDR_BLOCK"
#   tcp_options {

#     destination_port_range {
#       #Required
#       max = 80
#       min = 80
#     }
#     # source_port_range {
#     #   #Required
#     #   max = var.network_security_group_security_rule_tcp_options_source_port_range_max
#     #   min = var.network_security_group_security_rule_tcp_options_source_port_range_min
#     # }
#   }
# }

resource "oci_core_network_security_group" "for_compute_instance" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.this.id

  display_name = "${var.namespace}-compute_instance-nsg"
}

resource "oci_core_network_security_group_security_rule" "for_compute_instance" {
  network_security_group_id = oci_core_network_security_group.for_compute_instance.id
  direction                 = "INGRESS"
  protocol                  = "6"

  description = "Allow HTTP traffic from ${oci_load_balancer_load_balancer.this.display_name} to ${oci_core_instance.this.display_name}"
  #   destination = var.network_security_group_security_rule_destination
  #   destination_type = var.network_security_group_security_rule_destination_type

  source      = oci_core_network_security_group.for_lb.id // Allows connections from any IPv4 address.
  source_type = "NETWORK_SECURITY_GROUP"
  tcp_options {

    destination_port_range {
      #Required
      max = 8080
      min = 8080
    }
    # source_port_range {
    #   #Required
    #   max = var.network_security_group_security_rule_tcp_options_source_port_range_max
    #   min = var.network_security_group_security_rule_tcp_options_source_port_range_min
    # }
  }
}
