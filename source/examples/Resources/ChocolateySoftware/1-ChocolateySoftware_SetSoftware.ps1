
<#PSScriptInfo

.VERSION 0.0.2

.GUID 20cd6d2b-4af2-46cc-b5a8-0f0c61d7e5c5

.AUTHOR Gael Colas

.COMPANYNAME SynEdgy Limited

.COPYRIGHT (c) 2021 Gael Colas. All rights reserved.

.TAGS

.LICENSEURI https://github.com/chocolatey-community/Chocolatey/blob/master/LICENSE

.PROJECTURI https://github.com/chocolatey-community/Chocolatey/

.ICONURI https://blog.chocolatey.org/assets/images/chocolatey-icon.png

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Updated author, copyright notice, and URLs.

.PRIVATEDATA

#>

<#

.DESCRIPTION
 This is an unofficial module with DSC resource to Install and configure Chocolatey.

#>

param ()

configuration Example
{
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateySoftware ChococacheLocation {
            Ensure = 'Present'
            InstallationDirectory  = 'C:\Temp\Choco'
        }
    }
}


# So there something
