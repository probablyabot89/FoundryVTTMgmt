```markdown
# Foundry VTT Automation for Azure

This repository contains scripts for automating management tasks for Foundry VTT hosts on Azure. The goal is to provide a simple command-line tool using batch/powershell scripts to set up an Azure instance with Docker, manage network configurations, save and shut down the instance, and a quick boot up and load into gam capabilities for Foundry VTT.

## User Story

As a user, I can download this repository onto my PC and use batch/powershell scripts to interact with Azure and Docker. This allows for easy setup of an Azure instance with the necessary configurations for Foundry VTT, including saving and shutting down the instance, and later booting up with loading capabilities.

## Setup

1. Clone this repository to your local machine:

   ```bash
   git clone https://github.com/your-username/foundry-azure-automation.git
   cd foundry-azure-automation
   ```

2. Run the initialization script to set up the Azure VM and Foundry VTT:

   ```bash
   ./initialize-foundry-azure.ps1
   ```

   This script creates the Azure VM, installs Docker, and sets up Foundry VTT.

3. Save and shut down the instance when not in use:

   ```bash
   ./save-foundry-azure.ps1
   ```

   This script saves the game state, shuts down the Docker instance, and stops the server.

4. Boot up and load Foundry VTT when needed:

   ```bash
   ./start-foundry-azure.ps1
   ```

   This script starts the server, Docker instance, and loads the save state if available.

## Structure

The repository is organized with separate scripts for initialization, saving, and starting to ensure simplicity and ease of future migrations. Adjust configurations and resource names as needed for your setup.
