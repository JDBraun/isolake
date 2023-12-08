output "locked_private_access_setting_id" {
  description = "The private access setting ID from this module"
  value       = databricks_mws_private_access_settings.pas_lockdown.private_access_settings_id
}