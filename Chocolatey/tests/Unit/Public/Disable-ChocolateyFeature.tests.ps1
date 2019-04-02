InModuleScope Chocolatey {
    Describe Disable-ChocolateyFeature {

        Mock Get-Command -MockWith { Get-Command Write-Output } -ParameterFilter {$Name -eq 'choco.exe'}
        Mock Get-ChocolateyFeature -MockWith {
            'MyChocoFeature'
        }
        Mock Get-ChocolateyDefaultArgument -MockWith { 'TestArgument' }
        
        Context 'Default' {

            It 'Should call Get-Command' {
                $null = Disable-ChocolateyFeature -Name 'TestFeature'
                {Assert-MockCalled Get-Command} | Should -Not Throw
            }

            It 'Should call Get-ChocolateyFeature' {
                $null = Disable-ChocolateyFeature -Name 'TestFeature'
                {Assert-MockCalled Get-ChocolateyFeature} | Should -Not Throw
            }
            
            It 'Should not return value' {
                $return = Disable-ChocolateyFeature -Name 'TestFeature'
                $return | Should -BeNullOrEmpty
            }
        }
    }
}