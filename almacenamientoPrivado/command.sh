# Crear un grupo de recursos
az group create --name grupoAlmacenamientoPrivado --location "eastus2"

# Crea una cuenta de almacenamiento con acceso denegado publico
az storage account create --name platziprivado --resource-group grupoAlmacenamientoPrivado --location eastus2 --sku Standard_LRS --kind StorageV2 --access-tier Hot --default-action Deny

# Crear una red virtual y subred
az network vnet create --name platzi-vnet --resource-group grupoAlmacenamientoPrivado --location eastus2 --address-prefix 10.0.0.0/16 --subnet-name platzi-subred --subnet-prefix 10.0.0.0/24

# Actualiza el tipo de endpoint de la subred para Azure Storage (disponibiliza)
az network vnet subnet update --name platzi-subred --vnet-name platzi-vnet --resource-group grupoAlmacenamientoPrivado --service-endpoints Microsoft.Storage

# Agregar una regla de acceso para que solo la subred pueda acceder a la cuenta de almacenamiento
az storage account network-rule add --resource-group grupoAlmacenamientoPrivado --account-name platziprivado --vnet-name platzi-vnet --subnet platzi-subred

# Comando para crear una máquina virtual en la misma Vnet
az vm create --resource-group grupoAlmacenamientoPrivado --name vm-platzi-endpoint --vnet-name platzi-vnet --subnet platzi-subred --image Ubuntu2404 --admin-username azureuser --generate-ssh-keys --output none

# Muestra la IP de la maquina virtual
VM_PUBLIC_IP=$(az vm list-ip-addresses --resource-group grupoAlmacenamientoPrivado --name vm-platzi-endpoint --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" --output tsv)

# Permite el acceso a la cuenta de almacenamiento desde la Ip publica de la VM
az storage account network-rule add --resource-group grupoAlmacenamientoPrivado --account-name platziprivado --ip-address $VM_PUBLIC_IP

# obtener el key de acceso de la cuenta de almacenamiento
STORAGE_KEY=$(az storage account keys list --account-name platziprivado --resource-group grupoAlmacenamientoPrivado --query "[0].value" -o tsv)

# mostrar la credenciales de la VM de ubunto
echo "ssh azureuser@VM_PUBLIC_IP"

#en la maquina virtual instalar lo siguiente:
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

#Prueba de integridad
# Crear un contenedor en la cuenta de almacenamiento desde mi local (nose va poder porque la vnet solo le da permiso a la VM)
az storage container create --name prueba-conectividad --account-name platziprivado --account-key $STORAGE-KEY