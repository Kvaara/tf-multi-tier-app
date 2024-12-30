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
