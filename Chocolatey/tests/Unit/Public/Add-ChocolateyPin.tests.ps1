InModuleScope Chocolatey {
    Describe Add-ChocolateyPin {

        Mock Get-Command -MockWith { Get-Command Write-Output } -ParameterFilter {$Name -eq 'choco.exe'}
        Mock Get-ChocolateyFeature -MockWith {
            'MyChocoPackage'
        }
        Mock Get-ChocolateyDefaultArgument -MockWith { 'TestArgument' }
        
        Context 'Default' {

            It 'Should call Get-Command' {
                $null = Add-ChocolateyPin -Name 'TestPackage'
                {Assert-MockCalled Get-Command} | Should not Throw
            }

            It 'Should call Get-ChocolateyFeature' {
                $null = Add-ChocolateyPin -Name 'TestPackage'
                {Assert-MockCalled Get-ChocolateyFeature} | Should not Throw
            }
            
            It 'Should not return value' {
                $return = Add-ChocolateyPin -Name 'TestPackage'
                $return | Should BeNullOrEmpty
            }
        }
    }
}