BeforeAll {
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Continue'
    $ModulePath = (Join-Path -Path (Join-Path $Env:TEMP 'verifier') -ChildPath 'modules')
    $packageZipPath = Join-Path -Path $ModulePath -ChildPath 'GCPackages/ChocolateyIsInstalled*.zip'
    $packageZip = Get-Item -Path $packageZipPath -errorAction SilentlyContinue
}
Describe 'Test ChocolateyIsInstalled Package' {
    it 'Package should be available' {

        Test-Path -Path $packageZip | Should -be $true -because (gci (split-path -parent $packageZipPath))
        { Import-Module -Name 'GuestConfiguration' -ErrorAction 'Stop' } | Should -not -Throw
        Test-Path -Path $packageZip | Should -be $true
    }

    it 'Gets the ChocolateyIsInstalled Package Compliance Status' {

        $result = $null
        Start-GuestConfigurationPackageRemediation -Path $packageZip -Verbose -WarningAction SilentlyContinue

        $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip
        $result.Resources.Reasons | Should -not -BeNullOrEmpty
        $result.complianceStatus | Should -be $false
    }

    it 'Gets the non-compliant InstalledApplicationLinux @(''powershell-preview'',''somethingNotInstalled'') Package Compliance Status (with params)' {

        # $result = $null
        # $result = Get-GuestConfigurationPackageComplianceStatus -Path $packageZip -Parameter @{
        #     ResourceType = "GC_InstalledApplicationLinux"
        #     ResourceId = "InstalledApplicationLinux"
        #     ResourcePropertyName =  "AttributesYmlContent"
        #     ResourcePropertyValue = "powershell;somethingNotInstalled"
        # }

        # $result.Resources.Reasons | Should -not -BeNullOrEmpty
        # $result.complianceStatus | Should -be $false
    }
}
