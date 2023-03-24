BeforeAll {
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Continue'
    $ModulePath = (Join-Path -Path (Join-Path $Env:TEMP 'verifier') -ChildPath 'modules')
    $packageZipPath = Join-Path -Path $ModulePath -ChildPath 'GCPackages/ChocolateyIsInstalled*.zip'
    $packageZip = Get-Item -Path $packageZipPath -errorAction SilentlyContinue

    Import-Module (Join-Path -Path $ModulePath -ChildPath 'Chocolatey') -Verbose:$false
    if (Test-ChocolateyInstall)
    {
        Uninstall-Chocolatey -ErrorAction 'SilentlyContinue'
    }
}
Describe 'Test ChocolateyIsInstalled Package' {
    it 'Package should be available' {

        Test-Path -Path $packageZip | Should -be $true -because (gci (split-path -parent $packageZipPath))
        { Import-Module -Name 'GuestConfiguration' -ErrorAction 'Stop' } | Should -not -Throw
        Test-Path -Path $packageZip | Should -be $true
    }

    it 'Gets the ChocolateyIsInstalled Package Compliance Status (non-compliant)' {

        $result = $null
        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip
        $result.Resources.Reasons | Should -not -BeNullOrEmpty
        $result.complianceStatus | Should -be $false
    }

    it 'Remediates the ChocolateyIsInstalled Package (and return compliant)' {
        $result = Start-GuestConfigurationPackageRemediation -Path $packageZip
        $result.complianceStatus | Should -be $true
    }

    it 'Remediates the non-compliant ChocolateyIsInstalled with Putty as param' {

        $result = $null
        $result = Start-GuestConfigurationPackageRemediation -Path $packageZip -Parameter @{
            ResourceType = "ChocolateyPackage"
            ResourceId = "chocoSoftwareInstalled"
            ResourcePropertyName =  "Name"
            ResourcePropertyValue = "putty.portable"
        }

        $result.Resources.Reasons | Should -not -BeNullOrEmpty
        $result.complianceStatus | Should -be $true
    }
}
