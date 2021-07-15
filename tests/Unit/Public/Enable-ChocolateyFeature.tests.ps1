InModuleScope Chocolatey {
    Describe Enable-ChocolateyFeature {

        Mock Get-Command -MockWith { Get-Command Write-Output } -ParameterFilter {$Name -eq 'choco.exe'}
        Mock Get-ChocolateyFeature -MockWith {
            'MyChocoFeature'
        }
        Mock Get-ChocolateyDefaultArgument -MockWith { 'TestArgument' }
        
        Context 'Default' {

            It 'Should call Get-Command' {
                $null = Enable-ChocolateyFeature -Name 'TestFeature'
                {Assert-MockCalled Get-Command} | Should not Throw
            }

            It 'Should call Get-ChocolateyFeature' {
                $null = Enable-ChocolateyFeature -Name 'TestFeature'
                {Assert-MockCalled Get-ChocolateyFeature} | Should not Throw
            }
            
            It 'Should not return value' {
                $return = Enable-ChocolateyFeature -Name 'TestFeature'
                $return | Should -BeNullOrEmpty
            }
        }
    }
}