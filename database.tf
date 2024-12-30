// Remember... The password will be stored as plaintext in the Terraform state file!
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "oci_mysql_mysql_db_system" "this" {
  availability_domain = data.oci_identity_availability_domains.these.availability_domains[0].name
  compartment_id      = var.tenancy_ocid
  shape_name          = var.mysql_shape
  subnet_id           = oci_core_subnet.private.id
  admin_password      = random_password.password.result
  admin_username      = "admin"
  description         = "MySQL database for multi-tiered application"
  display_name        = "${var.namespace}-mysql-db"
  hostname_label      = "mysql-db"
  port                = 3306
}
