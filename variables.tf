variable "tenancy_ocid" {
  description = "Specifies the root compartment's (the so-called genesis compartment) ocid. This is also your Tenancy OCID."
  type        = string
}

variable "namespace" {
  description = "Used as a baseline for naming. This is purely cosmetic and has not functional purposes."
  type        = string
}

variable "compute_shape" {
  description = "Used to denote your Compute Instance's shape. Shapes determine how powerful your instance can get, and also whether it is Bare-Metal (BM) and/or has a GPU. See all of the shapes here: https://docs.oracle.com/en-us/iaas/data-science/using/supported-shapes.htm"
  type        = string
}
variable "vcn_cidr_blocks" {
  description = "A list of strings each of which specifies what CIDR block to reserve from the main VCN."
  type        = list(string)
}

variable "public_ssh_key" {
  description = "Your public SSH key, which, if correctly specified, enables access with your private SSH key into the compute instance."
  type        = string
  default     = null
}

variable "shape_config" {
  description = "The amount of memory (RAM) and ocpus. 1 OCPU equals 2 vCPUS. Shape configurations are limited by your Compute Instance's compute shape."
  type = object({
    memory_in_gbs = number
    ocpus         = number
  })
}

variable "mysql_db_info" {
  description = "Configuration information used during MySQL DB system bootstrapping."
  type = object({
    port           = number
    hostname_label = string
    admin_username = string
    # Specifies one of the many MySQL shapes available. The full list of shapes can be seen here: https://docs.oracle.com/en-us/iaas/mysql-database/doc/supported-shapes.html#GUID-BD6612A8-F06F-4EE8-92AA-F9A6AE6BDA75 
    mysql_shape = string
    db_name     = string
  })
}

variable "compute_instance_image" {
  description = "Specifies the OS Platform Image (PI) that will be fetched via a data source from OCI and given to the Compute Instance hosting the multi-tier web application."
  type = object({
    operating_system         = string
    operating_system_version = string
  })
}
