#!/bin/bash

# Crear grupo de recursos
az group create --name grupoBastion --location eastus2

# Crear red virtual
az network vnet create --resource-group grupoBastion --location eastus2 --name vnet-1 --address-prefixes 10.0.0.0/16 --subnet-name subnet-1 --subnet-prefixes 10.0.0.0/24

# Crear subnet para Azure Bastion
az network vnet subnet create --resource-group grupoBastion --name AzureBastionSubnet --vnet-name vnet-1 --address-prefixes 10.0.1.0/26

# Crear IP pública
az network public-ip create --resource-group grupoBastion --name public-ip --sku Standard --zone 1 2 3

# Crear Azure Bastion
az network bastion create --resource-group grupoBastion --name bastion --public-ip-address public-ip --vnet-name vnet-1 --location eastus2

# Crear máquina virtual
az vm create --resource-group grupoBastion --name vm-1 --image Win2022Datacenter --public-ip-address "" --vnet-name vnet-1 --subnet subnet-1 --admin-username azureuser --admin-password Am0_Apr3nd3r$