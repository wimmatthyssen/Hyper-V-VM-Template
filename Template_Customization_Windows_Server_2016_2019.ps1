<#
.Synopsis

A script used to customize a template for Windows Server 2016 or 2019.

.Description

A script used to customize a Windows Server 2016 or 2019 virtual machine (VM) template (base image).
When all customizations are set, you will be asked to reboot the server to apply all changes.

.Notes

File Name:      Template_Customization_Windows_Server_2016_2019.ps1
Created:        09/09/2019
Last modified:  10/05/2020
Author:         Wim Matthyssen
PowerShell:     5.1 or above 
Requires:       -RunAsAdministrator
OS:             Windows Server 2016 and Windows Server 2019
Version:        2.0
Action:         Change variables were needed to fit your needs
Disclaimer:     This script is provided "As Is" with no warranties.

.Example

.\Template_Customization_Windows_Server_2016_2019.ps1

.LINK

https://tinyurl.com/y3wmsh7o
#>

## Variables

$serverName = "vm-tmpl-w2k19"
$driveLabel = "OS"
$tempFolder = "C:\Temp"
$timezone = "Romance Standard Time"
$powerManagement = "High performance"
$cdromDriveletter = "z:"
$adminIEsecurityregpath = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$adminIEsecuritykey = "IsInstalled"
$windowsBuildNumber = (Get-WmiObject Win32_OperatingSystem).BuildNumber
$interActiveLogonregpath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$interActiveLogonkey = "DontDisplayLastUsername"
$regkeyPathUAC = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regkeyRDPPrinterMapping = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$regkeyServerManager = "HKLM:\SOFTWARE\Microsoft\ServerManager"
$regkeyWindowsDiagnosticLevel = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$oldLocalAdministratorName = "Administrator"
$newLocalAdministratorName = "y_local-stnadmin"
$password = "Sup3rS3cr3tP@ssword" | ConvertTo-SecureString -AsPlainText -Force
$windowsServer2016 = "14393"
$windowsServer2019 = "17763"
$writeEmptyLine = "`n"
$writeSeperator = " - "
$time = Get-Date -UFormat "%A %m/%d/%Y %R"
$foregroundColor1 = "Yellow"
$foregroundColor2 = "Red"

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Write Download started

Write-Host ($writeEmptyLine + "# Template custimization started" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Enable Remote Desktop and add Windows Firewall exception

Import-Module NetSecurity
(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1) | Out-Null
(Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null
Get-NetFirewallRule -DisplayName "Remote Desktop*" | Set-NetFirewallRule -enabled true
Write-Host ($writeEmptyLine + "# Remote Deskopt enabled" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 
 
##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Enable secure RDP authentication Network Level Authentication (NLA)

Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1
Write-Host ($writeEmptyLine + "# RDP NLA enabled" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Allow ICMP (ping) through Windows Firewall IPv4 and IPv6

New-NetFirewallRule -Name Allow_Ping_ICMPv4 -DisplayName "Allow Ping ICMPv4" -Description "Packet Internet Groper ICMPv4" -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow
New-NetFirewallRule -Name Allow_Ping_ICMPv6 -DisplayName "Allow Ping ICMPv6" -Description "Packet Internet Groper ICMPv6" -Protocol ICMPv6 -IcmpType 8 -Enabled True -Profile Any -Action Allow
Write-Host ($writeEmptyLine + "# Allowed ping trough firewall" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine  

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Disable guest account

net user guest /active:no
Disable-LocalUser -Name "guest"
Write-Host ($writeEmptyLine + "# Guest account disabled" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Disable RDP printer mapping

Set-ItemProperty -Path $regkeyRDPPrinterMapping  -Name fDisableCpm -Value 1
Write-Host ($writeEmptyLine + "# RDP printer mapping disabled" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Disable WAC pop-up in Server Manager on Windows Server 2019

## 

If ($windowsBuildNumber -eq $windowsServer2019)
	{
		New-ItemProperty -Path $regkeyServerManager -Name 'DoNotPopWACConsoleAtSMLaunch' -PropertyType 'DWord' -Value '1' -Force | Out-Null
		Write-Host ($writeEmptyLine + "# WAC pop-up disabled in Server Manager" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 
	}

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Remove description of the Local Administrator Account

Set-LocalUser -Name $oldLocalAdministratorName -Description ""
Write-Host ($writeEmptyLine + "# Description removed from Local Administrator Account" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set Local Administrator password

$userAccount = Get-LocalUser -Name $oldLocalAdministratorName
$userAccount | Set-LocalUser -Password $password
Write-Host ($writeEmptyLine + "# Local Administrator password set" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Rename Local Administrator Account

Rename-LocalUser -Name $oldLocalAdministratorName -NewName $newLocalAdministratorName
Write-Host ($writeEmptyLine + "# Local Administrator renamed" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set volume label of C: to OS

$drive = Get-WmiObject win32_volume -Filter "DriveLetter = 'C:'"
$drive.Label = $driveLabel
$drive.put()
Write-Host ($writeEmptyLine + "# Volumelabel of C: set to $driveLabel" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Change CD-ROM drive letter

(Get-WmiObject Win32_cdromdrive).drive | ForEach-Object{$a = mountvol $_ /l;mountvol $_ /d;$a = $a.Trim();mountvol $cdromDriveletter $a}
Write-Host ($writeEmptyLine + "# CD-ROM driveletter set to $$cdromDriveletter" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create the C:\Temp folder if not exists

If(!(test-path $tempFolder))
{
New-Item -ItemType Directory -Force -Path $tempFolder
}
Write-Host ($writeEmptyLine + "# $tempFolder created" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set Windows Diagnostic level (Telemetry) to Security

New-ItemProperty -Path $regkeyWindowsDiagnosticLevel -Name 'AllowTelemetry' -PropertyType 'DWord' -Value '0' -Force | Out-Null
Write-Host ($writeEmptyLine + "# Windows Diagnostic level (Telemetry) set to Security" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set Time Zone

Set-TimeZone -Name $timezone
Write-Host ($writeEmptyLine + "# Timezone set to $timezone" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set Power Management to High Performance if it is not currently the active plan

Try {
        $highPerf = powercfg -l | ForEach-Object{if($_.contains($powerManagement)) {$_.split()[3]}}
        $currPlan = $(powercfg -getactivescheme).split()[3]
        if ($currPlan -ne $highPerf) {powercfg -setactive $highPerf}
    } Catch {
        Write-Warning -Message "Unable to set power plan to $powerManagement" -foregroundcolor $foregroundColor2
    }
Write-Host ($writeEmptyLine + "# Power Management set to $powerManagement" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Disable IE security for Administrators

Set-ItemProperty -Path $adminIEsecurityregpath -Name $adminIEsecuritykey -Value 0
Stop-Process -Name Explorer
Write-Host ($writeEmptyLine + "# Done Disabling IE Enhanced Security Configuration for the Administrator" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set the Interactive Login to "Do not display the last user name"

Set-ItemProperty -Path $interActiveLogonregpath -Name $interActiveLogonkey -Value 1
Write-Host ($writeEmptyLine + "# Interactive Login set to - Do not display last user name" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Enable User Account Control (UAC) 

 Set-ItemProperty -Path $regkeyPathUAC -Name "EnableLUA" -Value 1
 Write-Host ($writeEmptyLine + "# User Access Control (UAC) enalbed" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set Windows Server 2016 or 2019 Automatic Virtual Machine Activation (AVMA) key

If ($windowsBuildNumber -eq $windowsServer2016)
	{
		slmgr /ipk C3RCX-M6NRP-6CXC9-TW2F2-4RHYD
		Write-Host ($writeEmptyLine + "# Windows Server 2016 Standard AVMA key set" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 
	}
Else 
	{
		slmgr /ipk TNK62-RXVTB-4P47B-2D623-4GF74
		Write-Host ($writeEmptyLine + "# Windows Server 2019 Standard AVMA key set" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 
	}

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Rename server

Rename-Computer –NewName $serverName
Write-Host ($writeEmptyLine + "# Server renamed to $serverName" + $writeSeperator + $time) -foregroundcolor $foregroundColor1 $writeEmptyLine 

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Restart server to apply all changes

Write-Host ($writeEmptyLine + "# This server will restart to apply all changes" + $writeSeperator + $time) -foregroundcolor $foregroundColor2 $writeEmptyLine 
Restart-Computer -ComputerName localhost

##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

