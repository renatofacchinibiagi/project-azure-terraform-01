resource "azurerm_public_ip" "web" {
  count = var.vm_count

  name                = format("%s-%02d", var.public_ip_name_prefix, count.index + 1)
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "web" {
  count = var.vm_count

  name                = format("%s-%02d", var.network_interface_name_prefix, count.index + 1)
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig-primary"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  count = var.vm_count

  name                            = format("%s-%02d", var.vm_name_prefix, count.index + 1)
  location                        = azurerm_resource_group.lab.location
  resource_group_name             = azurerm_resource_group.lab.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.web[count.index].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init/cloud-init.yaml.tftpl", {
    index_html_base64 = base64encode(file("${path.module}/app/index.html"))
  }))

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = var.tags
}