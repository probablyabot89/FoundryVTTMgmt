# FoundryAPI.psm1

<#
.SYNOPSIS
A module for interacting with Foundry VTT API.

.DESCRIPTION
This module provides functions to authenticate with Foundry VTT API, discover and select API endpoints, and send data to the selected endpoint. It also includes fun features for managing games, players, chat, dice rolling, entity spawning, and simulating events.

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
function Get-FoundryAPIEndpoints {
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
function Invoke-FoundryAPICall {
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

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint 'games' -Data $body
}

# Function to get game details from Foundry VTT
function Get-FoundryGameDetails {
    param (
        $Connection,
        [string]$GameId
    )

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId" -Data @{}
}

# Function to update game settings in Foundry VTT
function Set-FoundryGameSettings {
    param (
        $Connection,
        [string]$GameId,
        [hashtable]$Settings
    )

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId/settings" -Data $Settings
}

# Function to start or stop Foundry VTT server
function Toggle-FoundryServer {
    param (
        $Connection,
        [string]$GameId,
        [bool]$Start
    )

    $action = if ($Start) { 'start' } else { 'stop' }

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId/$action" -Data @{}
}

# Function to get player information
function Get-FoundryPlayers {
    param (
        $Connection,
        [string]$GameId
    )

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId/players" -Data @{}
}

# Function to send in-game chat messages
function Send-FoundryChatMessage {
    param (
        $Connection,
        [string]$GameId,
        [string]$Message
    )

    $body = @{
        content = $Message
    }

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId/chat" -Data $body
}

# Function to roll virtual dice
function Roll-FoundryDice {
    param (
        $Connection,
        [string]$GameId,
        [string]$Formula
    )

    $body = @{
        formula = $Formula
    }

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId/roll" -Data $body
}

# Function to spawn a creature or item in the game
function Spawn-FoundryEntity {
    param (
        $Connection,
        [string]$GameId,
        [string]$EntityName,
        [int]$X,
        [int]$Y
    )

    $body = @{
        name = $EntityName
        x    = $X
        y    = $Y
    }

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId/entities/spawn" -Data $body
}

# Function to simulate a random event in the game
function Simulate-FoundryEvent {
    param (
        $Connection,
        [string]$GameId,
        [string]$EventType
    )

    $body = @{
        type = $EventType
    }

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId/events/simulate" -Data $body
}

# Function to get list of available entities in the game
function Get-FoundryEntities {
    param (
        $Connection,
        [string]$GameId
    )

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId/entities" -Data @{}
}

# Function to move an entity to a new position
function Move-FoundryEntity {
    param (
        $Connection,
        [string]$GameId,
        [string]$EntityId,
        [int]$X,
        [int]$Y
    )

    $body = @{
        x = $X
        y = $Y
    }

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId/entities/$EntityId/move" -Data $body
}

# Function to delete an entity from the game
function Remove-FoundryEntity {
    param (
        $Connection,
        [string]$GameId,
        [string]$EntityId
    )

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId/entities/$EntityId/remove" -Data @{}
}

# Function to simulate a weather change in the game
function Simulate-FoundryWeather {
    param (
        $Connection,
        [string]$GameId,
        [string]$WeatherType
    )

    $body = @{
        type = $WeatherType
    }

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId/weather/simulate" -Data $body
}

# Function to create a custom game event
function Trigger-FoundryCustomEvent {
    param (
        $Connection,
        [string]$GameId,
        [string]$EventName,
        [string]$EventData
    )

    $body = @{
        name = $EventName
        data = $EventData
    }

    return Invoke-FoundryAPICall -Connection $Connection -Endpoint "games/$GameId/events/trigger" -Data $body
}