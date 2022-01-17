<#
.SYNOPSIS

A script used to download, install and configure the latest BgInfo version on a Windows Server 2012 R2.

.DESCRIPTION

A script used to download, install and configure the latest BgInfo version (v4.28) on a Windows Server 2012 R2. 
The BgInfo folder will be created on the C: drive if the folder does not already exist. 
Then the latest BgInfo.zip file will be downloaded and extracted in the BgInfo folder. 
The LogonBgi.zip file which holds the preferred settings will also be downloaded and extracted to the BgInfo folder. 
After extraction both .zip files will be deleted. 
A registry key (regkey) to AutoStart the BgInfo tool in combination with the logon.bgi config file will be created. 
At the end of the script BgInfo will be started for the first time and the PowerShell window will be closed.

.NOTES

File Name:      Deploy-BgInfo-WS2012-R2.ps1
Created:        17/09/2018
Last modified:  16/01/2022
Author:         Wim Matthyssen
PowerShell:     4.0 or above 
Requires:       -RunAsAdministrator
OS:             Windows Server 2012 R2
Version:        2.0
Action:         Change variables were needed to fit your needs
Disclaimer:     This script is provided "As Is" with no warranties.

.EXAMPLE

.\Deploy-BgInfo-WS2012-R2.ps1

.LINK

https://wmatthyssen.com/2019/09/11/powershell-bginfo-automation-script-for-windows-server-2012-r2/
#>

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Variables

$bgInfoFolder = "C:\BgInfo"
$bgInfoFolderContent = $bgInfoFolder + "\*"
$itemType = "Directory"
$bgInfoUrl = "https://download.sysinternals.com/files/BGInfo.zip"
$bgInfoZip = "C:\BgInfo\BgInfo.zip"
$bgInfoEula = "C:\BgInfo\Eula.txt"
$logonBgiUrl = "https://tinyurl.com/yxlxbgun"
$logonBgiZip = "C:\BgInfo\LogonBgi.zip"
$bgInfoRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$bgInfoRegkey = "BgInfo"
$bgInfoRegType = "String"
$bgInfoRegkeyValue = "C:\BgInfo\Bginfo.exe C:\BgInfo\logon.bgi /timer:0 /nolicprompt"
$regKeyExists = (Get-Item $bgInfoRegPath -EA Ignore).Property -contains $bgInfoRegkey

$foregroundColor1 = "Red"
$foregroundColor2 = "Yellow"
$writeEmptyLine = "`n"

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Start script execution

Write-Host ($writeEmptyLine + "# BgInfo deployment script started")`
-foregroundcolor $foregroundColor1 $writeEmptyLine 
 
## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create BgInfo folder on C: if it not exists, else delete it's content

If (!(Test-Path -Path $bgInfoFolder))
{
       New-Item -ItemType $itemType -Force -Path $bgInfoFolder
       Write-Host ($writeEmptyLine + "# BgInfo folder created")`
       -foregroundcolor $foregroundColor2 $writeEmptyLine
}
Else
{
       Write-Host ($writeEmptyLine + "# BgInfo folder already exists")`
       -foregroundcolor $foregroundColor2 $writeEmptyLine
       Remove-Item $bgInfoFolderContent -Force -Recurse -ErrorAction SilentlyContinue
       Write-Host ($writeEmptyLine + "# Content existing BgInfo folder deleted")`
       -foregroundcolor $foregroundColor2 $writeEmptyLine
}

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Download, save and extract latest BgInfo software to C:\BgInfo

Import-Module BitsTransfer
Start-BitsTransfer -Source $bgInfoUrl -Destination $bgInfoZip
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($bgInfoZip, $bgInfoFolder)
Remove-Item $bgInfoZip
Remove-Item $bgInfoEula

Write-Host ($writeEmptyLine + "# bginfo.exe available")`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Download, save and extract logon.bgi file to C:\BgInfo

Invoke-WebRequest -Uri $logonBgiUrl -OutFile $logonBgiZip
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($logonBgiZip, $bgInfoFolder)
Remove-Item $logonBgiZip

Write-Host ($writeEmptyLine + "# logon.bgi available")`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create BgInfo Registry Key to AutoStart

If ($regKeyExists -eq $True)
{
   Write-Host ($writeEmptyLine + "# BgInfo regkey exists, script wil go on")`
   -foregroundcolor $foregroundColor1 $writeEmptyLine
}
Else
{
   New-ItemProperty -Path $bgInfoRegPath -Name $bgInfoRegkey -PropertyType $bgInfoRegType -Value $bgInfoRegkeyValue

   Write-Host ($writeEmptyLine + "# BgInfo regkey added")`
   -foregroundcolor $foregroundColor2 $writeEmptyLine
}

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Run BgInfo

C:\BgInfo\Bginfo.exe C:\BgInfo\logon.bgi /timer:0 /nolicprompt

Write-Host ($writeEmptyLine + "# BgInfo has ran for the first time")`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Exit PowerShell window 3 seconds after completion

Write-Host ($writeEmptyLine + "# Script completed, the PowerShell window will close in 3 seconds")`
-foregroundcolor $foregroundColor1 $writeEmptyLine
Start-Sleep 3 
stop-process -Id $PID 

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
