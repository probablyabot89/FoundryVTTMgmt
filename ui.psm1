# UI.psm1

<#
.SYNOPSIS
A module for creating a colorful UI with a customizable heads-up display to manage Azure, Foundry VTT API, and remote Docker functions.

.DESCRIPTION
This module provides functions to create a vibrant user interface with a customizable heads-up display for managing Azure resources, interacting with Foundry VTT API, and controlling remote Docker instances.

.NOTES
File Name      : UI.psm1
Prerequisite   : PowerShell v5.1 or later
#>

# Import required modules from the root directory
Import-Module "$PSScriptRoot\Azure.psm1"
Import-Module "$PSScriptRoot\FoundryAPI.psm1"
Import-Module "$PSScriptRoot\Docker.psm1"

# Function to set console color
function Set-ConsoleColor {
    param (
        [System.ConsoleColor]$color
    )

    $Host.UI.RawUI.ForegroundColor = $color
}

# Function to execute selected menu option
function Execute-MenuOption {
    param (
        [string]$option
    )

    switch ($option) {
        '1' { Show-AzureMenu }
        '2' { Show-FoundryMenu }
        '3' { Show-DockerMenu }
        '4' { Write-Host "Exiting..." }
        default { Write-Host "Invalid option. Please try again." }
    }
}

# Function to display main menu
function Show-MainMenu {
    Set-ConsoleColor -color Yellow
    Write-Host "======================================="
    Write-Host "          Welcome to My UI              "
    Write-Host "======================================="
    Write-Host "1. Azure Functions"
    Write-Host "2. Foundry VTT API Functions"
    Write-Host "3. Remote Docker Functions"
    Write-Host "4. Quit"
    Write-Host "======================================="
    Set-ConsoleColor -color White
}

# Function to execute selected Azure menu option
function Execute-AzureMenuOption {
    param (
        [string]$option
    )

    switch ($option) {
        '1' { Create-AzureResourceGroup }
        '2' { Monitor-AzureCosts }
        '3' { Remove-AzureResources }
        'B' { Show-MainMenu }
        default { Write-Host "Invalid option. Please try again." }
    }
}

# Function to execute selected Foundry VTT API menu option
function Execute-FoundryMenuOption {
    param (
        [string]$option
    )

    switch ($option) {
        '1' { Initialize-FoundryAzure }
        '2' { Stop-FoundryServer }
        '3' { Remove-FoundryAzure }
        '4' { Monitor-AzureCosts }
        'B' { Show-MainMenu }
        default { Write-Host "Invalid option. Please try again." }
    }
}

# Function to execute selected Remote Docker menu option
function Execute-DockerMenuOption {
    param (
        [string]$option
    )

    switch ($option) {
        '1' { Start-FoundryContainer }
        '2' { Stop-FoundryContainer }
        '3' { Remove-FoundryContainer }
        '4' { Invoke-FoundryAPI }
        'B' { Show-MainMenu }
        default { Write-Host "Invalid option. Please try again." }
    }
}

# Function to run the UI
function Run-UI {
    $menuOption = ''

    while ($menuOption -ne '4') {
        Show-MainMenu
        $menuOption = Read-Host "Select an option"

        Execute-MenuOption -option $menuOption
    }
}

# Run the UI
Run-UI