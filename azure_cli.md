# Azure CLI Reference

## Install
- Windows: install Docker Desktop? No, Azure CLI install from https://aka.ms/installazurecliwindows
- Verify: `az --version`
- Common install:
  winget install Microsoft.AzureCLI

## Authenticate
- `az login`
- `az account list --output table`
- `az account set --subscription "<name or id>"`
- `az login --tenant <tenant-id>` for tenant-specific login

## Defaults
- `az configure --defaults group=<rg> location=<location>`
- `az account show`

## Resource management
- Create resource group: `az group create -n <name> -l <location>`
- Create storage account: `az storage account create -n <name> -g <rg> -l <location> --sku Standard_LRS`
- Create VM: `az vm create -g <rg> -n <vm> --image UbuntuLTS --admin-username azureuser`

## Azure service commands
- AKS: `az aks create -g <rg> -n <cluster> --node-count 3`
- ACR: `az acr create -g <rg> -n <registry> --sku Standard`
- Key Vault: `az keyvault create -g <rg> -n <vault>`

## Extensions
- Install extension: `az extension add --name <extension>`
- List extensions: `az extension list`
- Example: `az extension add --name azure-devops`

## Troubleshooting
- Clear cache: `az account clear`
- Refresh token: `az login`
- Show command errors: `az --debug <command>`
