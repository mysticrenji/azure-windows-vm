provider "azurerm" {
  features {}
}

# module "compute" {
#   source  = "Azure/compute/azurerm"
#   version = "3.14.0"
#   # insert the 3 required variables here
# }

resource "azurerm_resource_group" "medium" {
  name     = "medium-vm"
  location = "eastus2"
}

module "windowsservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.medium.name
  is_windows_image    = true
  vm_hostname         = "mysticrenji" // line can be removed if only one VM module per resource group
  admin_password      = "Get-AZVM -Name *vmname* | Select-Object -ExpandProperty OSProfile
"
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["mysticrenji"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.network.vnet_subnets[0]
  extra_disks = [
    {
      size = 200
      name = "backup"
    }
  ]

  depends_on = [azurerm_resource_group.medium]
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.medium.name
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["subnet1"]

  depends_on = [azurerm_resource_group.medium]
}

output "windows_vm_public_name" {
  value = module.windowsservers.public_ip_dns_name
}