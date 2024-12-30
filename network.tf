resource "oci_core_vcn" "this" {
  compartment_id = var.tenancy_ocid

  cidr_blocks  = var.vcn_cidr_blocks // Private CIDR block based on RFC 1918. Reserves 14 IP addresses.
  display_name = "${var.namespace}-vcn"
  dns_label    = "multitierapp"
}

resource "oci_core_subnet" "public" {
  cidr_block                 = cidrsubnet(oci_core_vcn.this.cidr_blocks[0], 1, 0) // 172.16.0.0 - 172.16.0.7
  compartment_id             = var.tenancy_ocid
  vcn_id                     = oci_core_vcn.this.id
  prohibit_public_ip_on_vnic = false
  display_name               = "${var.namespace}-public-subnet"
  dns_label                  = "publicsubnet"
}

resource "oci_core_subnet" "private" {
  cidr_block                 = cidrsubnet(oci_core_vcn.this.cidr_blocks[0], 1, 1) // 172.16.0.8 - 172.16.0.15
  compartment_id             = var.tenancy_ocid
  vcn_id                     = oci_core_vcn.this.id
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.namespace}-private-subnet"
  dns_label                  = "privatesubnet"
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

  source      = "0.0.0.0/0" // Allows connections from any IPv4 address.
  source_type = "CIDR_BLOCK"
  tcp_options {

    destination_port_range {
      #Required
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "for_lb2" {
  network_security_group_id = oci_core_network_security_group.for_lb.id
  direction                 = "EGRESS"
  protocol                  = "6"

  description      = "Allow egress connections towards ${oci_core_instance.this.display_name}."
  destination      = oci_core_network_security_group.for_compute_instance.id
  destination_type = "NETWORK_SECURITY_GROUP"

  tcp_options {
    destination_port_range {
      #Required
      max = 8080
      min = 8080
    }
  }
}

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

  source      = oci_core_network_security_group.for_lb.id // Allows connections from any IPv4 address.
  source_type = "NETWORK_SECURITY_GROUP"
  tcp_options {

    destination_port_range {
      #Required
      max = 8080
      min = 8080
    }
  }
}

// MySQL Databases in OCI don't support NSGs so you have to use security lists as the primary firewalls.
// In a production environment, default security lists shouldn't be used.
// You should create a self-contained security list and assign it to the private subnet where MySQL DB resides. 
resource "oci_core_default_security_list" "this" {
  manage_default_resource_id = oci_core_vcn.this.default_security_list_id
  ingress_security_rules {
    source      = "${oci_core_instance.this.private_ip}/32"
    source_type = "CIDR_BLOCK"
    description = "Allow MySQL database to accept connections from ${oci_core_instance.this.display_name}."
    protocol    = 6
    tcp_options {
      min = 3306
      max = 3306
    }
  }

  egress_security_rules {
    destination      = "${oci_mysql_mysql_db_system.this.ip_address}/32"
    destination_type = "CIDR_BLOCK"
    description      = "Allow egress connections towards ${oci_mysql_mysql_db_system.this.display_name}."
    protocol         = 6
    tcp_options {
      min = 3306
      max = 3306
    }
  }
}
