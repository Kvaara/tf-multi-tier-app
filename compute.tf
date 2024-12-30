resource "oci_core_instance" "this" {
  availability_domain = data.oci_identity_availability_domains.these.availability_domains[0].name
  compartment_id      = var.tenancy_ocid // A subcompartment below root would be more ideal 
  shape               = var.compute_shape
  display_name        = "${var.namespace}-instance"

  create_vnic_details {
    # assign_public_ip = ""
    display_name = "${var.namespace}-instance-primary-vnic"
    nsg_ids      = [oci_core_network_security_group.for_compute_instance.id]
    subnet_id    = oci_core_subnet.private.id
  }

  metadata = { "user-data" : data.cloudinit_config.this.rendered }

  shape_config {
    memory_in_gbs = 4
    ocpus         = 1
  }

  source_details {
    #Required
    # source_id = oci_core_image.test_image.id
    source_type = "image"

    #Optional
    # boot_volume_size_in_gbs = var.instance_source_details_boot_volume_size_in_gbs
    # boot_volume_vpus_per_gb = var.instance_source_details_boot_volume_vpus_per_gb
    instance_source_image_filter_details {
      compartment_id = var.tenancy_ocid

      operating_system         = "Canonical Ubuntu"
      operating_system_version = "24.04"
    }
  }
}
