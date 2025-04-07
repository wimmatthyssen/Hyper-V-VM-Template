# Hyper-V-VM-Template

This repository contains PowerShell scripts used to automate and ease up a Hyper-V VM template creation process. 

First of all to save time, but also to reduce errors and to ensure consistency by eliminating the need for repetitive configuration changes and performance tweaks.

Because I do a lot of research and testing, and therefore use a lot of different virtual machines (VM), which get build and rebuild, I mostly deploy them from a pre-configured template (base image or golden image).

Currenently this repository holds the following PowerShell scritps:

- **Create-Azure-Management-Groups-Tree-Hierarchy.ps1**

  More information about this script used to build a management groups tree structure can be found on my blog: https://wmatthyssen.com/2022/04/04/azure-powershell-script-create-a-management-group-tree-hierarchy/

Template_Customization_Windows_Server_2016_2019; Deploy-BgInfo-WS2012-R2; Deploy-BgInfo-WS2016-WS2019-WS2022

More information about the Template Customization Windows Server 2016/2019 script can be found on my blog: https://wmatthyssen.com/2020/05/11/powershell-set-customizations-for-a-windows-server-2016-or-2019-base-image/

More information about the BgInfo 2012 R2 script can be found on my blog: https://wmatthyssen.com/2019/09/11/powershell-bginfo-automation-script-for-windows-server-2012-r2/

More information about the BgInfo 2016/2019/2022/2025 script can be found on my blog: https://wmatthyssen.com/2019/09/09/powershell-bginfo-automation-script-for-windows-server-2016-2019/

