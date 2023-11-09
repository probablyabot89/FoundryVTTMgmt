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

# Function to set the remote Docker host
function Set-RemoteDockerHost {
    <#
    .SYNOPSIS
    Sets the remote Docker host for interaction.

    .DESCRIPTION
    This function sets the remote Docker host for interaction.

    .PARAMETER RemoteHostIP
    The IP address of the remote Docker host.

    .EXAMPLE
    Set-RemoteDockerHost -RemoteHostIP "192.168.1.100"
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$RemoteHostIP
    )

    try {
        Set-Variable -Name remoteHost -Value "tcp://$RemoteHostIP:2375" -Scope Global -Force
        Write-Host "Remote Docker host set to $RemoteHostIP."
    } catch {
        Write-Error "Failed to set remote Docker host. $_"
    }
}

# Function to start Foundry VTT Docker container
function Start-FoundryContainer {
    <#
    .SYNOPSIS
    Starts a Foundry VTT Docker container.

    .DESCRIPTION
    This function starts a Foundry VTT Docker container.

    .PARAMETER ContainerName
    The name of the container.

    .PARAMETER Image
    The Docker image to use for the container.

    .EXAMPLE
    Start-FoundryContainer -ContainerName "foundry-container" -Image "foundryvtt/image"
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$ContainerName = "foundry-container",

        [Parameter(Mandatory=$true)]
        [string]$Image
    )

    try {
        $existingContainer = Get-DockerContainer -Name $ContainerName -ErrorAction SilentlyContinue

        if ($existingContainer) {
            Write-Host "Container '$ContainerName' is already running."
        } else {
            docker run -d -p 30000:30000 --name $ContainerName $Image

            Write-Host "Started Foundry container '$ContainerName' on port 30000."
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

    .PARAMETER ContainerName
    The name of the container.

    .EXAMPLE
    Stop-FoundryContainer -ContainerName "foundry-container"
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$ContainerName = "foundry-container"
    )

    try {
        $existingContainer = Get-DockerContainer -Name $ContainerName -ErrorAction SilentlyContinue

        if ($existingContainer) {
            docker stop $ContainerName

            Write-Host "Stopped Foundry container '$ContainerName'."
        } else {
            Write-Host "Container '$ContainerName' is not currently running."
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

    .PARAMETER ContainerName
    The name of the container.

    .EXAMPLE
    Remove-FoundryContainer -ContainerName "foundry-container"
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$ContainerName = "foundry-container"
    )

    try {
        $existingContainer = Get-DockerContainer -Name $ContainerName -ErrorAction SilentlyContinue

        if ($existingContainer) {
            docker rm $ContainerName

            Write-Host "Removed Foundry container '$ContainerName'."
        } else {
            Write-Host "Container '$ContainerName' does not exist."
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

    .PARAMETER ContainerName
    The name of the container.

    .PARAMETER ApiEndpoint
    The API endpoint to invoke.

    .EXAMPLE
    Invoke-FoundryAPI -ContainerName "foundry-container" -ApiEndpoint "/some/endpoint"
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$ContainerName = "foundry-container",

        [Parameter(Mandatory=$true)]
        [string]$ApiEndpoint
    )

    try {
        $containerIP = (docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ContainerName).Trim()

        # Assuming Foundry VTT API runs on port 30000 (adjust accordingly)
        $apiURL = "http://$($containerIP):30000$ApiEndpoint"

        # Placeholder: Use Invoke-RestMethod or similar to interact with the API
    } catch {
        Write-Error "Failed to invoke Foundry VTT API. $_"
    }
}