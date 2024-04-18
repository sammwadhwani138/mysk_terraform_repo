#Creating a resource group
resource "azurerm_resource_group" "mysk_rg" {
  name     = "${var.v_env}-${var.v_prefix}-rg"
  location = var.v_location
}


#Creating a AKV and Secret
resource "random_password" "mysk_vm_admin_pass" {
  length=16
  special=true
}

resource "azurerm_key_vault" "mysk_akv" {
  name = "${var.v_env}-${var.v_akv_name}-akv"
  resource_group_name = azurerm_resource_group.mysk_rg.name
  sku_name = var.v_akv_sku
  tenant_id = data.azurerm_client_config.current.tenant_id
  location=var.v_location

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Set", 
      "Get", 
      "List"
    ]
  }
}

resource "azurerm_key_vault_secret" "mysk_akv_secret" {
  key_vault_id = azurerm_key_vault.mysk_akv.id
  name         = "${var.v_env}-${var.v_akv_name}-akv-admin-pass-new"
  value        = random_password.mysk_vm_admin_pass.result
  depends_on = [ azurerm_key_vault.mysk_akv ]
}

#Creating a VM
resource "azurerm_virtual_network" "mysk_vnet" {
  name                = "${var.v_prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mysk_rg.location
  resource_group_name = azurerm_resource_group.mysk_rg.name
}

resource "azurerm_subnet" "mysk_subnets" {
  name                 = "${var.v_prefix}-subnet-${count.index + 1}"
  count                = length(var.v_vm_subnet_cidr)
  resource_group_name  = azurerm_resource_group.mysk_rg.name
  virtual_network_name = azurerm_virtual_network.mysk_vnet.name
  address_prefixes     = [var.v_vm_subnet_cidr[count.index]]
}

resource "azurerm_network_interface" "mysk_nic" {
  count               = length(var.v_vm_subnet_cidr)
  name                = "${var.v_env}-${var.v_prefix}-nic"
  location            = azurerm_resource_group.mysk_rg.location
  resource_group_name = azurerm_resource_group.mysk_rg.name

  ip_configuration {
    name                          = "${var.v_env}-${var.v_prefix}-ip-configuration"
    subnet_id                     = azurerm_subnet.mysk_subnets[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main_vm" {
  name                  = "${var.v_env}-${var.v_prefix}-vm"
  location              = azurerm_resource_group.mysk_rg.location
  resource_group_name   = azurerm_resource_group.mysk_rg.name
  #network_interface_ids = [azurerm_network_interface.mysk_nic[*].id]
   network_interface_ids = [
    for nic in azurerm_network_interface.mysk_nic : nic.id
  ]
  vm_size               = "Standard_DS1_v2"
  depends_on = [ azurerm_key_vault_secret.mysk_akv_secret ]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  
  storage_os_disk {
    name              = "myskosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "${var.v_vm_admin_username}"
    admin_password =  azurerm_key_vault_secret.mysk_akv_secret.value
  }
  
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}