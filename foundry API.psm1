<#
.SYNOPSIS
A module for interacting with Foundry VTT API.

.DESCRIPTION
This module provides functions to authenticate with Foundry VTT API, discover and select API endpoints, and send data to the selected endpoint.

.NOTES
File Name      : FoundryAPI.psm1
Prerequisite   : PowerShell v5.1 or later
#>

# Function to authenticate with Foundry VTT API
function Connect-FoundryAPI {
    param (
        [string]$ServerUrl,
        [string]$ApiKey
    )

    $headers = @{
        'Content-Type'  = 'application/json'
        'Authorization' = "Bearer $ApiKey"
    }

    return @{
        ServerUrl = $ServerUrl
        ApiKey    = $ApiKey
        Headers   = $headers
    }
}

# Function to discover Foundry VTT API endpoints
function Discover-FoundryAPIEndpoints {
    param (
        $Connection
    )

    $response = Invoke-RestMethod -Uri "$($Connection.ServerUrl)/api" -Method Get -Headers $Connection.Headers

    return $response
}

# Function to select API endpoint for use
function Select-FoundryAPIEndpoint {
    param (
        $Endpoints
    )

    Write-Host "Available API Endpoints:"
    $index = 1
    foreach ($endpoint in $Endpoints.PSObject.Properties) {
        Write-Host "$index. $($endpoint.Name)"
        $index++
    }

    $selection = Read-Host "Select an API Endpoint by entering the corresponding number"
    $selectedEndpoint = $Endpoints.PSObject.Properties[$selection - 1].Name

    return $selectedEndpoint
}

# Function to send data to a selected API endpoint
function Send-FoundryAPIData {
    param (
        $Connection,
        [string]$Endpoint,
        [hashtable]$Data
    )

    $response = Invoke-RestMethod -Uri "$($Connection.ServerUrl)/api/$Endpoint" -Method Post -Headers $Connection.Headers -Body ($Data | ConvertTo-Json)

    return $response
}

# Function to create a new game in Foundry VTT
function New-FoundryGame {
    param (
        $Connection,
        [string]$GameName,
        [string]$System
    )

    $body = @{
        name   = $GameName
        system = $System
    }

    $response = Invoke-RestMethod -Uri "$($Connection.ServerUrl)/api/games" -Method Post -Headers $Connection.Headers -Body ($body | ConvertTo-Json)

    return $response
}

# Function to get game details from Foundry VTT
function Get-FoundryGameDetails {
    param (
        $Connection,
        [string]$GameId
    )

    $response = Invoke-RestMethod -Uri "$($Connection.ServerUrl)/api/games/$GameId" -Method Get -Headers $Connection.Headers

    return $response
}

# Function to update game settings in Foundry VTT
function Update-FoundryGameSettings {
    param (
        $Connection,
        [string]$GameId,
        [hashtable]$Settings
    )

    $response = Invoke-RestMethod -Uri "$($Connection.ServerUrl)/api/games/$GameId/settings" -Method Put -Headers $Connection.Headers -Body ($Settings | ConvertTo-Json)

    return $response
}

# Function to start or stop Foundry VTT server
function Toggle-FoundryServer {
    param (
        $Connection,
        [string]$GameId,
        [bool]$Start
    )

    $action = if ($Start) { "start" } else { "stop" }

    $response = Invoke-RestMethod -Uri "$($Connection.ServerUrl)/api/games/$GameId/$action" -Method Post -Headers $Connection.Headers

    return $response
}