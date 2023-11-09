# Import required modules
Import-Module Az

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

    # Create a new resource group
    az group create --name $ResourceGroup --location $Location

    # Create a public IP address
    az network public-ip create --resource-group $ResourceGroup --name $PublicIPAddress --sku Standard --allocation-method Dynamic

    # Create a network security group
    az network nsg create --resource-group $ResourceGroup --name "foundry-nsg" --location $Location

    # Create a rule in the network security group to allow traffic on specified ports
    az network nsg rule create --resource-group $ResourceGroup --nsg-name "foundry-nsg" --name "AllowFoundry" --priority 100 --source-address-prefix Internet --source-port-range "*" --destination-address-prefix "*" --destination-port-range $OpenPorts --access Allow

    # Create a virtual network
    az network vnet create --resource-group $ResourceGroup --name "foundry-vnet" --address-prefixes "10.0.0.0/16" --location $Location

    # Create a subnet and associate it with the virtual network
    az network vnet subnet create --resource-group $ResourceGroup --vnet-name "foundry-vnet" --name "foundry-subnet" --address-prefixes "10.0.0.0/24"

    # Create a network interface and associate it with the subnet
    az network nic create --resource-group $ResourceGroup --name "foundry-nic" --vnet-name "foundry-vnet" --subnet "foundry-subnet"

    # Create a virtual machine
    az vm create --resource-group $ResourceGroup --name $VMName --location $Location --size $VMSize --image UbuntuLTS --admin-username azureuser --generate-ssh-keys --nics "foundry-nic" --boot-diagnostics-storage "foundrydiagstorage"
}

# Function to stop Foundry server
function Stop-FoundryServer {
    param (
        [string]$ResourceGroup,
        [string]$VMName
    )

    # Stop Foundry server (e.g., Azure CLI commands)
    az vm deallocate --resource-group $ResourceGroup --name $VMName
}

# Function to delete Azure resources for Foundry
function Remove-FoundryAzure {
    param (
        [string]$ResourceGroup
    )

    # Remove Azure resources
    az group delete --name $ResourceGroup --yes --no-wait
}

# Function to monitor Azure costs
function Monitor-AzureCosts {
    param (
        [string]$ResourceGroup
    )

    # Calculate start and end date for the rolling last 4 months
    $endDate = Get-Date
    $startDate = (Get-Date).AddMonths(-4)

    # Format dates as required by Azure CLI
    $startDateFormatted = $startDate.ToString("yyyy-MM-dd")
    $endDateFormatted = $endDate.ToString("yyyy-MM-dd")

    # Monitor Azure costs
    Write-Host "Monitoring Azure costs for resources in group $ResourceGroup..."

    # Retrieve cost details using Azure Cost Management APIs
    $costDetails = az consumption usage list --start-date $startDateFormatted --end-date $endDateFormatted --query "[?contains('instanceName', '$ResourceGroup')].{Name: instanceName, Cost: preTaxCost}" --output table
    
    Write-Host "Cost Details for Resource Group: $ResourceGroup"
    Write-Host $costDetails
}

# Function to get key VM stats
function Get-FoundryVMStats {
    param (
        [string]$ResourceGroup,
        [string]$VMName
    )

    # Get CPU usage
    $cpuUsage = az monitor metrics list --resource $VMName --resource-group $ResourceGroup --metric "Percentage CPU" --output json | ConvertFrom-Json

    # Get memory usage
    $memoryUsage = az monitor metrics list --resource $VMName --resource-group $ResourceGroup --metric "Available Memory Bytes" --output json | ConvertFrom-Json

    # Get disk space usage
    $diskUsage = az monitor metrics list --resource $VMName --resource-group $ResourceGroup --metric "Disk Space Used" --output json | ConvertFrom-Json

    # Output PowerShell objects
    [PSCustomObject]@{
        VMName       = $VMName
        ResourceGroup = $ResourceGroup
        CPUUsage     = $cpuUsage
        MemoryUsage  = $memoryUsage
        DiskUsage    = $diskUsage
    }
}