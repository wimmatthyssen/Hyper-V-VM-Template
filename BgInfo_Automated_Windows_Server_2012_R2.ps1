<#
.SYNOPSIS

A script used to download, install and configure the latest BgInfo version on a Windows Server 2012 R2.

.DESCRIPTION

A script used to download, install and configure the latest BgInfo version (v4.27) on a Windows Server 2012 R2. The BgInfo folder will be created on the C: drive if the folder does not already exist. 
Then the latest BgInfo.zip file will be downloaded and extracted in the BgInfo folder. The LogonBgi.zip file which holds the preferred settings will also be downloaded and extracted to the BgInfo folder. 
After extraction both .zip files will be deleted. A registry key (regkey) to AutoStart the BgInfo tool in combination with the logon.bgi config file will be created. At the end of the script BgInfo will 
be started for the first time and the PowerShell window will be closed.

.NOTES

File Name:      BgInfo_Automated_Windows_Server_2012_R2.ps1
Created:        17/09/2018
Last modified:  12/09/2019
Author:         Wim Matthyssen
PowerShell:     4.0 or above 
Requires:       -RunAsAdministrator
OS:             Windows Server 2012 R2
Version:        2.0
Action:         Change variables were needed to fit your needs
Disclaimer:     This script is provided "As Is" with no warranties.

.EXAMPLE

.\BgInfo_Automated_Windows_Server_2012_R2.ps1

.LINK

https://tinyurl.com/yxpbq8la
#>

## Variables

$bgInfoFolder = "C:\BgInfo"
$bgInfoFolderContent = $bgInfoFolder + "\*"
$itemType = "Directory"
$bgInfoUrl = "https://download.sysinternals.com/files/BGInfo.zip"
$logonBgiUrl = "https://tinyurl.com/yxlxbgun"
$bgInfoZip = "C:\BgInfo\BgInfo.zip"
$bgInfoEula = "C:\BgInfo\Eula.txt"
$logonBgiZip = "C:\BgInfo\LogonBgi.zip"
$bgInfoRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$bgInfoRegkey = "BgInfo"
$bgInfoRegType = "String"
$bgInfoRegkeyValue = "C:\BgInfo\Bginfo.exe C:\BgInfo\logon.bgi /timer:0 /nolicprompt"
$regKeyExists = (Get-Item $bgInfoRegPath -EA Ignore).Property -contains $bgInfoRegkey
$writeEmptyLine = "`n"
$writeSeperator = " - "
$time = Get-Date
$foregroundColor1 = "Yellow"
$foregroundColor2 = "Red"

##-------------------------------------------------------------------------------------------------------------------------------------------------------

## Write Download started

Write-Host ($writeEmptyLine + "# BgInfo download started" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor1 $writeEmptyLine 

##-------------------------------------------------------------------------------------------------------------------------------------------------------

## Create BgInfo folder on C: if not exists

If (!(Test-Path -Path $bgInfoFolder)){New-Item -ItemType $itemType -Force -Path $bgInfoFolder
    Write-Host ($writeEmptyLine + "# BgInfo folder created" + $writeSeperator + $time)`
    -foregroundcolor $foregroundColor1 $writeEmptyLine
 }Else{Write-Host ($writeEmptyLine + "# BgInfo folder already exists" + $writeSeperator + $time)`
    -foregroundcolor $foregroundColor2 $writeEmptyLine
    Remove-Item $bgInfoFolderContent -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host ($writeEmptyLine + "# Content existing BgInfo folder deleted" + $writeSeperator + $time)`
    -foregroundcolor $foregroundColor2 $writeEmptyLine}

##-------------------------------------------------------------------------------------------------------------------------------------------------------

## Download, save and extract latest BgInfo software to C:\BgInfo

Import-Module BitsTransfer
Start-BitsTransfer -Source $bgInfoUrl -Destination $bgInfoZip
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($bgInfoZip, $bgInfoFolder)
Remove-Item $bgInfoZip
Remove-Item $bgInfoEula
Write-Host ($writeEmptyLine + "# bginfo.exe available" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor1 $writeEmptyLine

##-------------------------------------------------------------------------------------------------------------------------------------------------------

## Download, save and extract logon.bgi file to C:\BgInfo

Invoke-WebRequest -Uri $logonBgiUrl -OutFile $logonBgiZip
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($logonBgiZip, $bgInfoFolder)
Remove-Item $logonBgiZip
Write-Host ($writeEmptyLine + "# logon.bgi available" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor1 $writeEmptyLine

##-------------------------------------------------------------------------------------------------------------------------------------------------------

## Create BgInfo Registry Key to AutoStart

If ($regKeyExists -eq $True){Write-Host ($writeEmptyLine + "BgInfo regkey exists, script wil go on" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor2 $writeEmptyLine
}Else{
New-ItemProperty -Path $bgInfoRegPath -Name $bgInfoRegkey -PropertyType $bgInfoRegType -Value $bgInfoRegkeyValue
Write-Host ($writeEmptyLine + "# BgInfo regkey added" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor1 $writeEmptyLine}

##-------------------------------------------------------------------------------------------------------------------------------------------------------

## Run BgInfo

C:\BgInfo\Bginfo.exe C:\BgInfo\logon.bgi /timer:0 /nolicprompt
Write-Host ($writeEmptyLine + "# BgInfo has run" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor1 $writeEmptyLine

##-------------------------------------------------------------------------------------------------------------------------------------------------------

## Exit PowerShell window 3 seconds after completion

Write-Host ($writeEmptyLine + "# Script completed, the PowerShell window will close in 3 seconds" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor2 $writeEmptyLine
Start-Sleep 3 
stop-process -Id $PID 

##-------------------------------------------------------------------------------------------------------------------------------------------------------


