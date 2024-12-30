variable "tenancy_ocid" {
  type = string
}

variable "namespace" {
  type = string
}

variable "compute_shape" {
  type = string
}

variable "mysql_shape" {
  description = "Specifies one of the many MySQL shapes available. The full list of shapes can be seen here: https://docs.oracle.com/en-us/iaas/mysql-database/doc/supported-shapes.html#GUID-BD6612A8-F06F-4EE8-92AA-F9A6AE6BDA75 "
  type        = string
}

variable "vcn_cidr_blocks" {
  type = list(string)
}
