
<#PSScriptInfo

.VERSION 0.0.2

.GUID 4762a9ed-7cd2-415a-abe8-80a06dcb433f

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


configuration Chocolatey
{
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateySource ChocolateyOrg {
            Ensure   = 'Present'
            Name     = 'Chocolatey'
            Source   = 'https://chocolatey.org/api/v2'
            Priority = 0
            Disabled = $false
        }
    }
}
