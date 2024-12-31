data "oci_identity_availability_domains" "these" {
  compartment_id = var.tenancy_ocid
}

// This datasource is capable of rendering a multi-part MIME configuration that defines the Content-Type metadata.
data "cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  part {
    // All of the content types can be found here: 
    // https://cloudinit.readthedocs.io/en/latest/explanation/format.html#user-data-formats-content-types
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/cloud_config.yaml", local.db_config)
  }
}

data "oci_core_images" "these" {
  compartment_id = var.tenancy_ocid

  operating_system         = var.compute_instance_image.operating_system
  operating_system_version = var.compute_instance_image.operating_system_version
  sort_by                  = "DISPLAYNAME"
  shape                    = var.compute_shape
}

data "oci_core_services" "these" {
  filter {
    name   = "name"
    values = ["All"] // We want `all-arn-services-in-oracle-services-network`not only the Object Storage.
    regex  = true
  }
}
