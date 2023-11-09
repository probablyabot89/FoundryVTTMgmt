# Import required modules
Import-Module Az

<#
.SYNOPSIS
A module for managing Foundry VTT instances with Azure resources.

.DESCRIPTION
This module provides functions to initialize Azure resources, stop Foundry servers, remove Azure resources, monitor Azure costs, and get key VM stats.

.NOTES
File Name      : FoundryAzure.psm1
Prerequisite   : PowerShell v5.1 or later
#>

# Function to initialize Azure resources for Foundry
function Initialize-FoundryAzure {
    param (
        [string]$ResourceGroup,
        [string]$VMName,
        [string]$Location = "uksouth",
        [string]$VMSize = "Standard_B1ls",
        [string]$PublicIPAddress = "foundry-public-ip",
        [string]$OpenPorts = "30000"
    )

    az group create --name $ResourceGroup --location $Location
    az network public-ip create --resource-group $ResourceGroup --name $PublicIPAddress --sku Standard --allocation-method Dynamic
    az network nsg create --resource-group $ResourceGroup --name "foundry-nsg" --location $Location
    az network nsg rule create --resource-group $ResourceGroup --nsg-name "foundry-nsg" --name "AllowFoundry" --priority 100 --source-address-prefix Internet --source-port-range "*" --destination-address-prefix "*" --destination-port-range $OpenPorts --access Allow
    az network vnet create --resource-group $ResourceGroup --name "foundry-vnet" --address-prefixes "10.0.0.0/16" --location $Location
    az network vnet subnet create --resource-group $ResourceGroup --vnet-name "foundry-vnet" --name "foundry-subnet" --address-prefixes "10.0.0.0/24"
    az network nic create --resource-group $ResourceGroup --name "foundry-nic" --vnet-name "foundry-vnet" --subnet "foundry-subnet"
    az vm create --resource-group $ResourceGroup --name $VMName --location $Location --size $VMSize --image UbuntuLTS --admin-username azureuser --generate-ssh-keys --nics "foundry-nic" --boot-diagnostics-storage "foundrydiagstorage"
}

# Function to stop Foundry server
function Stop-FoundryServer {
    param (
        [string]$ResourceGroup,
        [string]$VMName
    )

    az vm deallocate --resource-group $ResourceGroup --name $VMName
}

# Function to delete Azure resources for Foundry
function Remove-FoundryAzure {
    param (
        [string]$ResourceGroup
    )

    az group delete --name $ResourceGroup --yes --no-wait
}

# Function to monitor Azure costs
function Monitor-AzureCosts {
    param (
        [string]$ResourceGroup
    )

    $endDate = Get-Date
    $startDate = (Get-Date).AddMonths(-4)
    $startDateFormatted = $startDate.ToString("yyyy-MM-dd")
    $endDateFormatted = $endDate.ToString("yyyy-MM-dd")

    Write-Host "Monitoring Azure costs for resources in group $ResourceGroup..."

    az consumption usage list --start-date $startDateFormatted --end-date $endDateFormatted --query "[?contains('instanceName', '$ResourceGroup')].{Name: instanceName, Cost: preTaxCost}" --output table
}

# Function to get key VM stats
function Get-FoundryVMStats {
    param (
        [string]$ResourceGroup,
        [string]$VMName
    )

    az monitor metrics list --resource $VMName --resource-group $ResourceGroup --metric "Percentage CPU" --output json | ConvertFrom-Json
    az monitor metrics list --resource $VMName --resource-group $ResourceGroup --metric "Available Memory Bytes" --output json | ConvertFrom-Json
    az monitor metrics list --resource $VMName --resource-group $ResourceGroup --metric "Disk Space Used" --output json | ConvertFrom-Json
}