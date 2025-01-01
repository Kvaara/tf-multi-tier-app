locals {
  server_config = {
    user                = var.mysql_db_info.admin_username
    password            = nonsensitive(random_password.password.result)
    database            = oci_mysql_mysql_db_system.this.display_name
    hostname            = oci_mysql_mysql_db_system.this.endpoints[0].hostname
    compute_instance_ip = local.compute_instance_ip
    mysql_db_ip         = local.mysql_db_ip
    mysql_db_port       = var.mysql_db_info.port
  }
  public_subnet_cidr_block  = cidrsubnet(oci_core_vcn.this.cidr_blocks[0], 1, 0) // 172.16.0.0 - 172.16.0.7
  private_subnet_cidr_block = cidrsubnet(oci_core_vcn.this.cidr_blocks[0], 1, 1) // 172.16.0.8 - 172.16.0.15
  compute_instance_ip       = cidrhost(local.private_subnet_cidr_block, 3)
  mysql_db_ip               = cidrhost(local.private_subnet_cidr_block, 4)
}
