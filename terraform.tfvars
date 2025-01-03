tenancy_ocid    = null
vcn_cidr_blocks = ["172.16.0.0/28"]
compute_shape   = "VM.Standard.E5.Flex"
namespace       = "tf-multi-tier-app"
shape_config = {
  memory_in_gbs = 4
  ocpus         = 1
}
mysql_db_info = {
  mysql_shape    = "MySQL.Free"
  port           = 3306
  admin_username = "admin"
  hostname_label = "mysql-db"
  db_name        = "pets"
}
compute_instance_image = {
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
}
