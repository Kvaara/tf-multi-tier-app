resource "oci_core_instance" "this" {
  availability_domain = data.oci_identity_availability_domains.these.availability_domains[0].name
  compartment_id      = var.tenancy_ocid // A subcompartment below root would be more ideal 
  shape               = var.compute_shape
  display_name        = "${var.namespace}-instance"

  create_vnic_details {
    display_name     = "${var.namespace}-instance-primary-vnic"
    nsg_ids          = [oci_core_network_security_group.for_compute_instance.id]
    subnet_id        = oci_core_subnet.private.id
    assign_public_ip = false
    private_ip       = local.compute_instance_ip
  }

  metadata = {
    ssh_authorized_keys = var.public_ssh_key
    user_data           = data.cloudinit_config.this.rendered
  }

  shape_config {
    memory_in_gbs = var.shape_config.memory_in_gbs
    ocpus         = var.shape_config.ocpus
  }

  source_details {
    source_id   = data.oci_core_images.these.images[0].id
    source_type = "image"
  }
}
