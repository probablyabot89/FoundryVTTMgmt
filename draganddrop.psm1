# Import required modules
Import-Module ".\FoundryAPI.psm1"

# Function to handle file drop events
function Invoke-FoundryFileAction {
    param (
        [string]$FilePath,
        [string]$ServerUrl,
        [string]$ApiKey,
        [string]$GameName,
        [string]$System,
        [string]$GameId
    )

    # Function to authenticate with Foundry VTT API
    $connection = Connect-FoundryAPI -ServerUrl $ServerUrl -ApiKey $ApiKey

    # Get the file extension
    $fileExtension = (Get-Item $FilePath).Extension.ToLower()

    # Check file type and perform actions
    switch ($fileExtension) {
        ".json" {
            # Import JSON object using Foundry API
            $jsonData = Get-Content $FilePath -Raw | ConvertFrom-Json
            New-FoundryGame -Connection $connection -GameName $GameName -System $System -GameData $jsonData
            break
        }
        ".png", ".jpg", ".jpeg" {
            # Upload image file using Foundry API
            Upload-FoundryImage -Connection $connection -GameId $GameId -FilePath $FilePath
            break
        }
        ".mp3", ".wav" {
            # Upload audio file using Foundry API
            Upload-FoundryAudio -Connection $connection -GameId $GameId -FilePath $FilePath
            break
        }
        ".js" {
            # Run Node script against live game using Foundry API
            $scriptContent = Get-Content $FilePath -Raw
            Invoke-FoundryNodeScript -Connection $connection -GameId $GameId -ScriptContent $scriptContent
            break
        }
        default {
            Write-Host "Unsupported file type."
            break
        }
    }
}

Export-ModuleMember -Function Invoke-FoundryFileAction