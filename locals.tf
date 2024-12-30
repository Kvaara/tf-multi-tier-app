locals {
  db_config = {
    user = "admin"
    // nonsensitive() function removes the sensitive marking metadata, overriding Terraform's conservative behavior and allowing outputting.
    password = nonsensitive(random_password.password.result)
    database = oci_mysql_mysql_db_system.this.display_name
    hostname = oci_mysql_mysql_db_system.this.endpoints[0].hostname
    port     = oci_mysql_mysql_db_system.this.endpoints[0].port
  }
}
