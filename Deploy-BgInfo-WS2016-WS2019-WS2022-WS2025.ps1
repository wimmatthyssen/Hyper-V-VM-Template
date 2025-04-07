<#
.SYNOPSIS

A script used to download, install, and configure the latest version of BgInfo on Windows Server 2016, 2019, 2022, or 2025.

.DESCRIPTION

A script used to download, install, and configure the latest version of BgInfo on Windows Server 2016, 2019, 2022, or 2025.
This script will do all of the following:

Check if PowerShell is running as Administrator, otherwise exit the script.
Create a BgInfo folder on the C: drive if it doesn't already exist; otherwise, delete its contents.
Download, save and extract latest BGInfo software to C:\BgInfo.
Download, save and extract logon.bgi file to C:\BgInfo.
Create BgInfo registry key for AutoStart.
Run BgInfo.

.NOTES

File Name:     Deploy-BgInfo-WS2016-WS2019-WS2022-WS2025.ps1
Created:       08/09/2019
Last Modified: 03/04/2025
Author:        Wim Matthyssen
PowerShell:    Version 5.1 or later
Requires:      -RunAsAdministrator
OS Support:    Windows Server 2016, 2019, 2022, and 2025
Version:       3.2
Note:          Update variables as needed to fit your environment
Disclaimer:    This script is provided "As Is" without any warranties.

.EXAMPLE

.\Deploy-BgInfo-WS2016-WS2019-WS2022-WS2025.ps1

.LINK

https://wmatthyssen.com/2025/04/07/powershell-script-bginfo-deployment-script-for-windows-server-2025/
#>

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Variables

$bgInfoFolder = "C:\BgInfo"
$bgInfoFolderContent = "$bgInfoFolder\*"
#$itemType = "Directory"
$bgInfoUrl = "https://download.sysinternals.com/files/BGInfo.zip"
$bgInfoZip = "C:\BgInfo\BGInfo.zip"
$bgInfoEula = "C:\BgInfo\Eula.txt"
$logonBgiUrl = "https://tinyurl.com/yxlxbgun"
$logonBgiZip = "$bgInfoFolder\LogonBgi.zip"
$bgInfoRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$bgInfoRegKey = "BgInfo"
#$bgInfoRegType = "String"
$bgInfoRegKeyValue = "C:\BgInfo\Bginfo64.exe C:\BgInfo\logon.bgi /timer:0 /nolicprompt"
#$regKeyExists = (Get-Item $bgInfoRegPath -EA Ignore).Property -contains $bgInfoRegkey

$global:currenttime= Set-PSBreakpoint -Variable currenttime -Mode Read -Action {$global:currenttime= Get-Date -UFormat "%A %m/%d/%Y %R"}
$foregroundColor1 = "Green"
$foregroundColor2 = "Yellow"
$foregroundColor3 = "Red"
$writeEmptyLine = "`n"
$writeSeperatorSpaces = " - "

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Check if PowerShell is running as Administrator, otherwise exit the script

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
   Write-Host ($writeEmptyLine + "# Please run PowerShell as Administrator" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor3 $writeEmptyLine
    exit
}
 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Write script started

Write-Host ($writeEmptyLine + "# Script started. Without errors, it can take up to 2 minutes to complete" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine 

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create a BgInfo folder on the C: drive if it doesn't already exist; otherwise, delete its contents

try {
   if (!(Test-Path -Path $bgInfoFolder)) {
       New-Item -ItemType Directory -Force -Path $bgInfoFolder | Out-Null
       Write-Host ($writeEmptyLine + "# BgInfo folder created at $bgInfoFolder" + $writeSeperatorSpaces + $currentTime)`
      -foregroundcolor $foregroundColor2 $writeEmptyLine
   } else {
       Remove-Item -Path $bgInfoFolderContent -Force -Recurse -ErrorAction SilentlyContinue
       Write-Host ($writeEmptyLine + "# Existing BgInfo folder content deleted" + $writeSeperatorSpaces + $currentTime)`
      -foregroundcolor $foregroundColor2 $writeEmptyLine
   }
} catch {
   Write-Host ($writeEmptyLine + "# Failed to create or clean BgInfo folder: $_" + "ERROR" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor3 $writeEmptyLine
   exit
}

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Download, save and extract latest BGInfo software to C:\BgInfo

try {
   # Import the BitsTransfer module to enable file transfer using Background Intelligent Transfer Service (BITS)
   Import-Module BitsTransfer -ErrorAction Stop
   # Download the BgInfo ZIP file from the specified URL and save it to the specified destination
   Start-BitsTransfer -Source $bgInfoUrl -Destination $bgInfoZip
   # Extract the contents of the downloaded ZIP file to the BgInfo folder
   Expand-Archive -LiteralPath $bgInfoZip -DestinationPath $bgInfoFolder -Force
   # Remove the ZIP file and the EULA file after extraction to clean up
   Remove-Item $bgInfoZip, $bgInfoEula -Force
   Write-Host ($writeEmptyLine + "# BgInfo downloaded and extracted successfully" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor2 $writeEmptyLine
} catch {
   Write-Host ($writeEmptyLine + "# Failed to download or extract BgInfo: $_" + "ERROR" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor3 $writeEmptyLine
   exit
}

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Download, save and extract logon.bgi file to C:\BgInfo

try {
   # Ensure TLS 1.2 is used for compatibility with modern HTTPS endpoints (required for Windows Server 2016)
   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
   # Download the logon.bgi file
   Invoke-WebRequest -Uri $logonBgiUrl -OutFile $logonBgiZip -ErrorAction Stop
   # Extract the ZIP file 
   Expand-Archive -LiteralPath $logonBgiZip -DestinationPath $bgInfoFolder -Force
   # Clean up the ZIP file
   Remove-Item $logonBgiZip -Force
   Write-Host ($writeEmptyLine + "# logon.bgi available" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor2 $writeEmptyLine
} catch {
   Write-Host ($writeEmptyLine + "# Failed to download or extract logon.bgi: $_" + "ERROR" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor3 $writeEmptyLine
   exit
}

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create BgInfo registry key for AutoStart

try {
   if (Get-ItemProperty -Path $bgInfoRegPath -Name $bgInfoRegKey -ErrorAction SilentlyContinue) {
      Write-Host ($writeEmptyLine + "# BgInfo registry key already exists" + $writeSeperatorSpaces + $currentTime)`
      -foregroundcolor $foregroundColor2 $writeEmptyLine 
   } else {
       New-ItemProperty -Path $bgInfoRegPath -Name $bgInfoRegKey -PropertyType String -Value $bgInfoRegKeyValue -Force | Out-Null
       Write-Host ($writeEmptyLine + "# BgInfo registry key created" + $writeSeperatorSpaces + $currentTime)`
      -foregroundcolor $foregroundColor2 $writeEmptyLine
   }
} catch {
   Write-Host ($writeEmptyLine + "# Failed to create BgInfo registry key: $_" + "ERROR" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor3 $writeEmptyLine
   exit
}

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Run BgInfo

try {
   Start-Process -FilePath "C:\BgInfo\Bginfo64.exe" -ArgumentList "C:\BgInfo\logon.bgi /timer:0 /nolicprompt" -NoNewWindow -Wait
   Write-Host ($writeEmptyLine + "# BgInfo executed successfully" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor2 $writeEmptyLine
   } catch {
      Write-Host ($writeEmptyLine + "# Failed to execute BgInfo: $_" + "ERROR" + $writeSeperatorSpaces + $currentTime)`
      -foregroundcolor $foregroundColor3 $writeEmptyLine
      exit
}

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Write script completed

Write-Host ($writeEmptyLine + "# Script completed" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine 

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

