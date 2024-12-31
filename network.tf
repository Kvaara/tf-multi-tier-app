resource "oci_core_vcn" "this" {
  compartment_id = var.tenancy_ocid

  cidr_blocks  = var.vcn_cidr_blocks // Private CIDR block based on RFC 1918. Reserves 14 IP addresses.
  display_name = "${var.namespace}-vcn"
  dns_label    = "multitierapp"
}

resource "oci_core_subnet" "public" {
  cidr_block                 = local.public_subnet_cidr_block
  compartment_id             = var.tenancy_ocid
  vcn_id                     = oci_core_vcn.this.id
  prohibit_public_ip_on_vnic = false
  display_name               = "${var.namespace}-public-subnet"
  dns_label                  = "publicsubnet"
  route_table_id             = oci_core_route_table.for_public_subnet.id
}

resource "oci_core_subnet" "private" {
  cidr_block                 = local.private_subnet_cidr_block
  compartment_id             = var.tenancy_ocid
  vcn_id                     = oci_core_vcn.this.id
  prohibit_public_ip_on_vnic = true
  display_name               = "${var.namespace}-private-subnet"
  dns_label                  = "privatesubnet"
  security_list_ids          = [oci_core_security_list.for_private_subnet.id]
  route_table_id             = oci_core_route_table.for_private_subnet.id
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

  description = "Allow HTTP traffic from outside to multi-tier web application LB."

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

  description      = "Allow egress connections towards multi-tier web application server."
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

resource "oci_core_network_security_group_security_rule" "for_compute_instance1" {
  network_security_group_id = oci_core_network_security_group.for_compute_instance.id
  direction                 = "INGRESS"
  protocol                  = "6"

  description = "Allow HTTP traffic from the multi-tier web application LB to the application server."

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

resource "oci_core_network_security_group_security_rule" "for_compute_instance2" {
  network_security_group_id = oci_core_network_security_group.for_compute_instance.id
  direction                 = "EGRESS"
  protocol                  = "6"

  description = "Allow any type of traffic to any IPv4 IP address via NAT Gateway (one-way/outbound). This is required for us to download the multi-tier web application server. Also allows MySQL management over TCP port 3306"

  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
}

resource "oci_core_nat_gateway" "this" {
  compartment_id = var.tenancy_ocid
  display_name   = "${var.namespace}-ngw"
  vcn_id         = oci_core_vcn.this.id
}

resource "oci_core_internet_gateway" "this" {
  display_name   = "${var.namespace}-igw"
  vcn_id         = oci_core_vcn.this.id
  compartment_id = var.tenancy_ocid
}

resource "oci_core_route_table" "for_private_subnet" {
  #Required
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.this.id

  display_name = "${var.namespace}-private-subnet-route-table"
  route_rules {
    network_entity_id = oci_core_nat_gateway.this.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    description       = "Allow route to NAT Gateway"
  }
}

resource "oci_core_route_table" "for_public_subnet" {
  #Required
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.this.id

  display_name = "${var.namespace}-public-subnet-route-table"
  route_rules {
    network_entity_id = oci_core_internet_gateway.this.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    description       = "Allow route to the outside world (public internet)."
  }
}

// Utilizing Security Lists is required because NSGs haven't been implemented for MySQL.
resource "oci_core_security_list" "for_private_subnet" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.namespace}-private-subnet-security-list"
  ingress_security_rules {
    source      = "${local.compute_instance_ip}/32"
    source_type = "CIDR_BLOCK"
    description = "Allow MySQL database to accept connections from multi-tier web application server."
    protocol    = 6
    tcp_options {
      min = 3306
      max = 3306
    }
  }
}
