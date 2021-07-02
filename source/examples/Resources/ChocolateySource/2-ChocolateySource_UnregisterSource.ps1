
<#PSScriptInfo

.VERSION 0.0.2

.GUID e94c172e-c710-4dd2-befe-7868d9790ef6

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
        ChocolateySource ChocolateyOrg {
            Ensure = 'Absent'
            Name   = 'Chocolatey'
        }
    }
}
