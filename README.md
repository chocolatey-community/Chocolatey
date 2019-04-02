# Chocolatey Module

[![Build status](https://ci.appveyor.com/api/projects/status/ulul0agv7kgo8a7n?svg=true)](https://ci.appveyor.com/project/gaelcolas/chocolatey)

This module intend to wrap around the [Chocolatey Software](https://chocolatey.org) binary, to create a PowerShell interface and provide DSC resources.
The module let you install the chocolatey binary from a Nuget feed, optionally specifying a version, Proxy and Credentials to use.

This project has adopted the Microsoft Open Source Code of Conduct.
For more information see the Code of Conduct FAQ or contact opencode@microsoft.com with any additional questions or comments.

## Content

This is the current content of the module, besides the file used for managing the project.

```txt
CHOCOLATEY\CHOCOLATEY
│   Chocolatey.psd1
│   Chocolatey.psm1
│
├───docs
├───DscResources
│   │   DSCResourcesDefinitions.json
│   │
│   ├───ChocolateyFeature
│   │       ChocolateyFeature.psm1
│   │       ChocolateyFeature.schema.mof
│   │
│   ├───ChocolateyPackage
│   │       ChocolateyPackage.psm1
│   │       ChocolateyPackage.schema.mof
│   │
│   ├───ChocolateyPin
│   │       ChocolateyPin.psm1
│   │       ChocolateyPin.schema.mof
│   │
│   ├───ChocolateySetting
│   │       ChocolateySetting.psm1
│   │       ChocolateySetting.schema.mof
│   │
│   |───ChocolateySoftware
│   │       ChocolateySoftware.psm1
│   │       ChocolateySoftware.schema.mof
|   |
│   └───ChocolateySource
│           ChocolateySource.psm1
│           ChocolateySource.schema.mof
│
├───examples
│       chocolateyConfig.ps1
│       dsc_configuration.ps1
│
├───private
│       Get-ChocolateyDefaultArguments.ps1
│       Get-Downloader.ps1
│       Get-RemoteFile.ps1
│       Get-RemoteString.ps1
│       Repair-PowerShellOutputRedirectionBug.ps1
│       Write-Host.ps1
│
├───public
│       Add-ChocolateyPin.ps1
|       Disable-ChocolateyFeature.ps1
│       Disable-ChocolateySource.ps1
│       Enable-ChocolateyFeature.ps1
│       Enable-ChocolateySource.ps1
│       Get-ChocolateyFeature.ps1
│       Get-ChocolateyPackage.ps1
|       Get-ChocolateyPin.ps1
│       Get-ChocolateySource.ps1
│       Get-ChocolateyVersion.ps1
│       Install-Chocolatey.ps1
│       Install-ChocolateyPackage.ps1
│       Install-ChocolateySoftware.ps1
│       Register-ChocolateySource.ps1
|       Remove-ChocolateyPin.ps1
│       Test-ChocolateyFeature.ps1
│       Test-ChocolateyInstall.ps1
│       Test-ChocolateyPackageIsInstalled.ps1
│       Test-ChocolateySource.ps1
│       Uninstall-Chocolatey.ps1
│       Uninstall-ChocolateyPackage.ps1
│       Unregister-ChocolateySource.ps1
│       Update-ChocolateyPackage.ps1
│
└───tests
    │
    ├───QA
    │
    └───Unit
        |
        |───Private
        |
        └───Public
```