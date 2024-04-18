data "azurerm_client_config" "current" {

}

# data "azurerm_key_vault" "mysk_akv" {
#   name                = "${var.v_akv_name}"
#   resource_group_name = "${var.v_provider_rg}"
# }

# data "azurerm_key_vault_secret" "mysk_akv_secret" {
#   name         = "${var.v_env}-${var.v_akv_name}-admin-pass"
#   key_vault_id = data.azurerm_key_vault.mysk_akv.id
#   #"/subscriptions/${var.v_subscription_id}/resourceGroups/${var.v_provider_rg}/providers/Microsoft.KeyVault/vaults/${var.v_akv_name}"
# }
