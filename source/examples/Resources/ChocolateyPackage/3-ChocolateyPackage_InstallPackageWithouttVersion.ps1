
<#PSScriptInfo

.VERSION 0.0.2

.GUID 69d21aea-6e14-4751-b649-b26205717148

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

Param()


configuration Chocolatey 
{
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateyPackage Putty {
            Ensure            = 'Present'
            Name              = 'Putty'
            ChocolateyOptions = @{ source = 'https://chocolatey.org/api/v2/' }
        }
    }
}
