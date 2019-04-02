InModuleScope Chocolatey {
    Describe Add-ChocolateyPin {

        Mock Get-Command -MockWith { Get-Command Write-Output } -ParameterFilter {$Name -eq 'choco.exe'}
        Mock Get-ChocolateyPin -MockWith {
            'MyChocoPackage'
        }
        Mock Get-ChocolateyDefaultArgument -MockWith { 'TestArgument' }
        
        Context 'Default' {

            It 'Should call Get-Command' {
                $null = Add-ChocolateyPin -Name 'TestPackage'
                {Assert-MockCalled Get-Command} | Should -Not Throw
            }

            It 'Should call Get-ChocolateyPin' {
                $null = Add-ChocolateyPin -Name 'TestPackage'
                {Assert-MockCalled Get-ChocolateyPin} | Should -Not Throw
            }
            
            It 'Should not return value' {
                $return = Add-ChocolateyPin -Name 'TestPackage'
                $return | Should -BeNullOrEmpty
            }
        }
    }
}