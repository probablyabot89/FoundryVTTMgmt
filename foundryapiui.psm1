# FoundryAPIExplorer.psm1

<#
.SYNOPSIS
A module for exploring Foundry VTT API endpoints interactively.

.DESCRIPTION
This module provides a UI for exploring Foundry VTT API endpoints, interacting with game state, and performing various actions.

.NOTES
File Name      : FoundryAPIExplorer.psm1
Prerequisite   : PowerShell v5.1 or later
#>

# Import required modules from the root directory
Import-Module "$PSScriptRoot\FoundryAPI.psm1"

# Function to set console color
function Set-ConsoleColor {
    param (
        [System.ConsoleColor]$color
    )

    $Host.UI.RawUI.ForegroundColor = $color
}

# Function to set default connection
function Set-DefaultFoundryAPIConnection {
    param (
        [string]$ServerUrl,
        [string]$ApiKey
    )

    return @{
        ServerUrl = $ServerUrl
        ApiKey    = $ApiKey
        Headers   = @{
            'Content-Type'  = 'application/json'
            'Authorization' = "Bearer $ApiKey"
        }
    }
}

# Function to display main menu
function Show-MainMenu {
    Set-ConsoleColor -color Yellow
    Write-Host "======================================="
    Write-Host "      Foundry VTT API Explorer          "
    Write-Host "======================================="
    Write-Host "1. Connect to Foundry API"
    Write-Host "2. Explore API Endpoints"
    Write-Host "3. Control Foundry"
    Write-Host "4. Exit"
    Write-Host "======================================="
    Set-ConsoleColor -color White
}

# Function to execute selected menu option
function Execute-MenuOption {
    param (
        [string]$option,
        [hashtable]$connection
    )

    switch ($option) {
        '1' { $connection = Connect-FoundryAPI }
        '2' { Explore-FoundryAPI -Connection $connection }
        '3' { Control-Foundry -Connection $connection }
        '4' { Write-Host "Exiting..." }
        default { Write-Host "Invalid option. Please try again." }
    }

    return $connection
}

# Function to run the Foundry API Explorer
function Run-FoundryAPIExplorer {
    $connection = @{}  # Default to an empty hashtable

    while ($true) {
        Show-MainMenu
        $menuOption = Read-Host "Select an option"

        if ($menuOption -eq '4') {
            break
        }

        $connection = Execute-MenuOption -option $menuOption -connection $connection
    }
}

# Run the Foundry API Explorer
Run-FoundryAPIExplorer