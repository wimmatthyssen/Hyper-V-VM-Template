<#
.SYNOPSIS

A script used to download, install and configure the latest BgInfo version on a Windows Server 2016 or 2019.

.DESCRIPTION

A script used to download, install and configure the latest BgInfo version (v4.27) on a Windows Server 2016 or 2019. The BgInfo folder will be created on the C: drive if the folder does not already exist. 
Then the latest BgInfo.zip file will be downloaded and extracted in the BgInfo folder. The LogonBgi.zip file which holds the preferred settings will also be downloaded and extracted to the BgInfo folder. 
After extraction both .zip files will be deleted. A registry key (regkey) to AutoStart the BgInfo tool in combination with the logon.bgi config file will be created. At the end of the script BgInfo will 
be started for the first time and the PowerShell window will be closed.

.NOTES

File Name:      BgInfo_Automated_Windows_Server_2016_2019.ps1
Created:        08/09/2019
Last modified:  13/09/2019
Author:         Wim Matthyssen
PowerShell:     5.1 or above 
Requires:       -RunAsAdministrator
OS:             Windows Server 2016 and Windows Server 2019
Version:        2.2
Action:         Change variables were needed to fit your needs
Disclaimer:     This script is provided "As Is" with no warranties.

.EXAMPLE

.\BgInfo_Automated_Windows_Server_2016_2019.ps1

.LINK

https://tinyurl.com/y3wmsh7o
#>

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
$writeEmptyLine = "`n"
$writeSeperator = " - "
$time = Get-Date -UFormat "%A %m/%d/%Y %R"
$foregroundColor1 = "Yellow"
$foregroundColor2 = "Red"

##-------------------------------------------------------------------------------------------------------------------------------------------------------

## Write Download started

Write-Host ($writeEmptyLine + "# BgInfo download started" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor1 $writeEmptyLine 

##-------------------------------------------------------------------------------------------------------------------------------------------------------

## Create BgInfo folder on C: if not exists, else delete its content

If (!(Test-Path -Path $bgInfoFolder)){New-Item -ItemType $itemType -Force -Path $bgInfoFolder
   Write-Host ($writeEmptyLine + "# BgInfo folder created" + $writeSeperator + $time)`
   -foregroundcolor $foregroundColor1 $writeEmptyLine
}Else{Write-Host ($writeEmptyLine + "# BgInfo folder already exists" + $writeSeperator + $time)`
   -foregroundcolor $foregroundColor2 $writeEmptyLine
   Remove-Item $bgInfoFolderContent -Force -Recurse -ErrorAction SilentlyContinue
   Write-Host ($writeEmptyLine + "# Content existing BgInfo folder deleted" + $writeSeperator + $time)`
   -foregroundcolor $foregroundColor2 $writeEmptyLine}

 ##-------------------------------------------------------------------------------------------------------------------------------------------------------

## Download, save and extract latest BGInfo software to C:\BgInfo

Import-Module BitsTransfer
Start-BitsTransfer -Source $bgInfoUrl -Destination $bgInfoZip
Expand-Archive -LiteralPath $bgInfoZip -DestinationPath $bgInfoFolder -Force
Remove-Item $bgInfoZip
Remove-Item $bgInfoEula
Write-Host ($writeEmptyLine + "# bginfo.exe available" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor1 $writeEmptyLine

##-------------------------------------------------------------------------------------------------------------------------------------------------------

## Download, save and extract logon.bgi file to C:\BgInfo

Invoke-WebRequest -Uri $logonBgiUrl -OutFile $logonBgiZip
Expand-Archive -LiteralPath $logonBgiZip -DestinationPath $bgInfoFolder -Force
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

C:\BgInfo\Bginfo64.exe C:\BgInfo\logon.bgi /timer:0 /nolicprompt
Write-Host ($writeEmptyLine + "# BgInfo has ran for the first time" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor1 $writeEmptyLine 

##-------------------------------------------------------------------------------------------------------------------------------------------------------

## Exit PowerShell window 2 seconds after completion

Write-Host ($writeEmptyLine + "# Script completed, the PowerShell window will close in 2 seconds" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor2 $writeEmptyLine
Start-Sleep 2 
stop-process -Id $PID 

##-------------------------------------------------------------------------------------------------------------------------------------------------------



