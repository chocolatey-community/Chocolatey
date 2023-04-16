
<#PSScriptInfo

.VERSION 0.0.2

.GUID 5994643b-ff32-430e-828d-1a3f5ec8067c

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
        ChocolateyPackage Putty {
            Ensure            = 'Present'
            Name              = 'Putty'
            Version           = 'Latest'
            ChocolateyOptions = @{
                source = 'https://chocolatey.org/api/v2/'
            }
        }
    }
}
