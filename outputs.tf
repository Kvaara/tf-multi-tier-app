output "cloudinit_config" {
  value = data.cloudinit_config.this.rendered
}

output "db_config" {
  value     = local.db_config
  sensitive = true
}
