# Import required modules
Import-Module DockerMsftProvider
Import-Module Docker

<#
.SYNOPSIS
A module for managing Foundry VTT instances with Docker.

.DESCRIPTION
This module provides functions to start, stop, and interact with Foundry VTT instances running in Docker.

.NOTES
File Name      : FoundryDocker.psm1
Prerequisite   : PowerShell v5.1 or later

#>

# Function to start Foundry VTT Docker container
function Start-FoundryContainer {
    <#
    .SYNOPSIS
    Starts a Foundry VTT Docker container.

    .DESCRIPTION
    This function starts a Foundry VTT Docker container.

    .PARAMETER containerName
    The name of the container.

    .PARAMETER image
    The Docker image to use for the container.

    .PARAMETER port
    The port to map to the container's 30000 port.

    .EXAMPLE
    Start-FoundryContainer -containerName "my-container" -image "foundryvtt/image" -port 40000
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$containerName,

        [Parameter(Mandatory=$true)]
        [string]$image,

        [Parameter(Mandatory=$true)]
        [int]$port
    )

    try {
        $existingContainer = Get-DockerContainer -Name $containerName -ErrorAction SilentlyContinue

        if ($existingContainer) {
            Write-Host "Container '$containerName' is already running."
        } else {
            docker run -d -p $port:30000 --name $containerName $image

            Write-Host "Started Foundry container '$containerName' on port $port."
        }
    } catch {
        Write-Error "Failed to start Foundry container. $_"
    }
}

# Function to stop Foundry VTT Docker container
function Stop-FoundryContainer {
    <#
    .SYNOPSIS
    Stops a Foundry VTT Docker container.

    .DESCRIPTION
    This function stops a Foundry VTT Docker container.

    .PARAMETER containerName
    The name of the container.

    .EXAMPLE
    Stop-FoundryContainer -containerName "my-container"
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$containerName
    )

    try {
        $existingContainer = Get-DockerContainer -Name $containerName -ErrorAction SilentlyContinue

        if ($existingContainer) {
            docker stop $containerName

            Write-Host "Stopped Foundry container '$containerName'."
        } else {
            Write-Host "Container '$containerName' is not currently running."
        }
    } catch {
        Write-Error "Failed to stop Foundry container. $_"
    }
}

# Function to remove Foundry VTT Docker container
function Remove-FoundryContainer {
    <#
    .SYNOPSIS
    Removes a Foundry VTT Docker container.

    .DESCRIPTION
    This function removes a Foundry VTT Docker container.

    .PARAMETER containerName
    The name of the container.

    .EXAMPLE
    Remove-FoundryContainer -containerName "my-container"
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$containerName
    )

    try {
        $existingContainer = Get-DockerContainer -Name $containerName -ErrorAction SilentlyContinue

        if ($existingContainer) {
            docker rm $containerName

            Write-Host "Removed Foundry container '$containerName'."
        } else {
            Write-Host "Container '$containerName' does not exist."
        }
    } catch {
        Write-Error "Failed to remove Foundry container. $_"
    }
}

# Function to interact with Foundry VTT API
function Invoke-FoundryAPI {
    <#
    .SYNOPSIS
    Invokes the Foundry VTT API.

    .DESCRIPTION
    This function interacts with the Foundry VTT API.

    .PARAMETER containerName
    The name of the container.

    .PARAMETER apiEndpoint
    The API endpoint to invoke.

    .EXAMPLE
    Invoke-FoundryAPI -containerName "my-container" -apiEndpoint "/some/endpoint"
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$containerName,

        [Parameter(Mandatory=$true)]
        [string]$apiEndpoint
    )

    try {
        $containerIP = (docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $containerName).Trim()

        # Assuming Foundry VTT API runs on port 30000 (adjust accordingly)
        $apiURL = "http://$($containerIP):30000$apiEndpoint"

        # Placeholder: Use Invoke-RestMethod or similar to interact with the API