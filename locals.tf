locals {
  db_config = {
    user     = "admin"
    password = random_password.password.result
    database = oci_mysql_mysql_db_system.this.display_name
    hostname = oci_mysql_mysql_db_system.this.endpoints[0].hostname
    port     = oci_mysql_mysql_db_system.this.endpoints[0].port
  }
}
