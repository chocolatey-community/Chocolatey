InModuleScope Chocolatey {
    Describe Install-ChocolateySoftware {

        Mock Get-RemoteFile -MockWith {}
        Mock Get-RemoteString -MockWith {
            "<result><feed><entry><content><src>https://chocolatey.org/api/v2/packages/chocolatey/0.10.8/</src></content></entry></feed></result>"
        }
        Mock Copy-Item -MockWith {}
        Mock Expand-Archive -MockWith {}
        Mock New-Item -MockWith {}
        Mock Repair-PowerShellOutputRedirectionBug {}
        Mock Join-Path -ParameterFilter {$ChildPath -eq 'chocolateyInstall.ps1'} -MockWith { {$true} }
        
        Context 'Default' {
            #Need to be first before Get-RemoteString has been called
            It 'Ensure Get-RemoteString is NOT called when install from Package URL' {
                $null = Install-ChocolateySoftware -ChocolateyPackageUrl 'https://chocolatey.org/api/v2/package/chocolatey/0.10.8/'
                { Assert-MockCalled Get-RemoteString } | Should Throw
            }

            It 'Ensure Get-RemoteString is called when install from Feed without version' {
                $null = Install-ChocolateySoftware
                { Assert-MockCalled Get-RemoteString } | Should -Not Throw
            }

            It 'Ensure Get-RemoteFile is called' {
                $null = Install-ChocolateySoftware
                { Assert-MockCalled Get-RemoteFile } | Should -Not Throw
            }

            if($PSVersionTable.PSVersion.Major -ge 5) {
                It 'Ensure Expand-Archive is called' {
                    $null = Install-ChocolateySoftware
                    { Assert-MockCalled Expand-Archive } | Should -Not Throw
                }
            }
        }
    }
}