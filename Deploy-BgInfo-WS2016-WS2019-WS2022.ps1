#Requires -Version 5.1 -RunAsAdministrator
<#
.SYNOPSIS

A script used to download, install and configure the latest BgInfo version on a Windows Server 2016, 2019 or 2022.

.DESCRIPTION

A script used to download, install and configure the latest BgInfo version (v4.28) on a Windows Server 2016, 2019 or 2022. 
The BgInfo folder will be created on the C: drive if the folder does not already exist. 
Then the latest BgInfo.zip file will be downloaded and extracted in the BgInfo folder. 
The LogonBgi.zip file which holds the preferred settings will also be downloaded and extracted to the BgInfo folder. 
After extraction both .zip files will be deleted. 
A registry key (regkey) to AutoStart the BgInfo tool in combination with the logon.bgi config file will be created. 
At the end of the script BgInfo will be started for the first time and the PowerShell window will be closed.

.NOTES

File Name:      Deploy-BgInfo-WS2016-WS2019-WS2022.ps1
Created:        08/09/2019
Last modified:  16/01/2022
Author:         Wim Matthyssen
PowerShell:     5.1 or above 
Requires:       -RunAsAdministrator
OS:             Windows Server 2016, Windows Server 2019 and Windows Server 2022
Version:        3.0
Action:         Change variables were needed to fit your needs
Disclaimer:     This script is provided "As Is" with no warranties.

.EXAMPLE

.\Deploy-BgInfo-WS2016-WS2019-WS2022.ps1

.LINK

https://wmatthyssen.com/2019/09/09/powershell-bginfo-automation-script-for-windows-server-2016-2019/
#>

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Variables

$bgInfoFolder = "C:\BgInfo"
$bgInfoFolderContent = $bgInfoFolder + "\*"
$itemType = "Directory"
$bgInfoUrl = "https://download.sysinternals.com/files/BGInfo.zip"
$bgInfoZip = "C:\BgInfo\BGInfo.zip"
$bgInfoEula = "C:\BgInfo\Eula.txt"
$logonBgiUrl = "https://tinyurl.com/yxlxbgun"
$logonBgiZip = "C:\BgInfo\LogonBgi.zip"
$bgInfoRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$bgInfoRegKey = "BgInfo"
$bgInfoRegType = "String"
$bgInfoRegKeyValue = "C:\BgInfo\Bginfo64.exe C:\BgInfo\logon.bgi /timer:0 /nolicprompt"
$regKeyExists = (Get-Item $bgInfoRegPath -EA Ignore).Property -contains $bgInfoRegkey

$global:currenttime= Set-PSBreakpoint -Variable currenttime -Mode Read -Action {$global:currenttime= Get-Date -UFormat "%A %m/%d/%Y %R"}
$foregroundColor1 = "Red"
$foregroundColor2 = "Yellow"
$writeEmptyLine = "`n"
$writeSeperatorSpaces = " - "

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Check if PowerShell is running as Administrator, otherwise exit the script

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdministrator -eq $false) 
{
    Write-Host ($writeEmptyLine + "# Please run PowerShell as Administrator" + $writeSeperatorSpaces + $currentTime)`
    -foregroundcolor $foregroundColor1 $writeEmptyLine
    exit
}
 
## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Start script execution

Write-Host ($writeEmptyLine + "# BgInfo deployment script started." + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine 
 
## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create BgInfo folder on C: if it not exists, else delete it's content

If (!(Test-Path -Path $bgInfoFolder))
{
   New-Item -ItemType $itemType -Force -Path $bgInfoFolder
   Write-Host ($writeEmptyLine + "# BgInfo folder created" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor2 $writeEmptyLine
}
Else
{
   Write-Host ($writeEmptyLine + "# BgInfo folder already exists" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor2 $writeEmptyLine
   Remove-Item $bgInfoFolderContent -Force -Recurse -ErrorAction SilentlyContinue
   Write-Host ($writeEmptyLine + "# Content existing BgInfo folder deleted" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor2 $writeEmptyLine
}

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Download, save and extract latest BGInfo software to C:\BgInfo

Import-Module BitsTransfer
Start-BitsTransfer -Source $bgInfoUrl -Destination $bgInfoZip
Expand-Archive -LiteralPath $bgInfoZip -DestinationPath $bgInfoFolder -Force
Remove-Item $bgInfoZip
Remove-Item $bgInfoEula

Write-Host ($writeEmptyLine + "# bginfo.exe available" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Download, save and extract logon.bgi file to C:\BgInfo

Invoke-WebRequest -Uri $logonBgiUrl -OutFile $logonBgiZip
Expand-Archive -LiteralPath $logonBgiZip -DestinationPath $bgInfoFolder -Force
Remove-Item $logonBgiZip

Write-Host ($writeEmptyLine + "# logon.bgi available" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create BgInfo Registry Key to AutoStart

If ($regKeyExists -eq $True)
{
   Write-Host ($writeEmptyLine + "# BgInfo regkey exists, script wil go on" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor1 $writeEmptyLine
}
Else
{
   New-ItemProperty -Path $bgInfoRegPath -Name $bgInfoRegkey -PropertyType $bgInfoRegType -Value $bgInfoRegkeyValue

   Write-Host ($writeEmptyLine + "# BgInfo regkey added" + $writeSeperatorSpaces + $currentTime)`
   -foregroundcolor $foregroundColor2 $writeEmptyLine
}

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Run BgInfo

C:\BgInfo\Bginfo64.exe C:\BgInfo\logon.bgi /timer:0 /nolicprompt

Write-Host ($writeEmptyLine + "# BgInfo has ran for the first time" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine 

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Exit PowerShell window 3 seconds after completion

Write-Host ($writeEmptyLine + "# Script completed, the PowerShell window will close in 3 seconds" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine
Start-Sleep 3 
stop-process -Id $PID 

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
