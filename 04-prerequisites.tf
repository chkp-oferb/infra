resource "azurerm_virtual_network" "myvnet" {
  name                = "${var.bdp-prefix}-${var.env}-${var.location}-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.dbdrg.location
  resource_group_name = azurerm_resource_group.dbdrg.name
}

# Create Subnet
resource "azurerm_subnet" "mysubnet" {
  #name                 = var.subnet_name
  name                 = "${var.bdp-prefix}-${var.env}-${var.location}-subnet"
  resource_group_name  = azurerm_resource_group.dbdrg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["10.1.0.0/24"]
}




