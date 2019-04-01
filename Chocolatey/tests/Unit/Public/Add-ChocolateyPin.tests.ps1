InModuleScope Chocolatey {
    Describe Add-ChocolateyPin {

        Mock Get-Command -MockWith { Get-Command Write-Output } -ParameterFilter {$Name -eq 'choco.exe'}
        Mock Get-ChocolateyPin -MockWith {
            'MyChocoPin'
        }

        Context 'Default' {

            It 'Should call Get-Command' {
                $null = Add-ChocolateyPin -Name 'TestPackage'
                {Assert-MockCalled Get-Command} | Should not Throw
            }

            It 'Should call Get-ChocolateyPin' {
                $null = Add-ChocolateyPin -Name 'TestPackage'
                {Assert-MockCalled Get-ChocolateyPin} | Should not Throw
            }

            It 'Should not return value' {
                $return = Add-ChocolateyPin -Name 'TestPackage'
                $return | Should BeNullOrEmpty
            }
        }
    }
}