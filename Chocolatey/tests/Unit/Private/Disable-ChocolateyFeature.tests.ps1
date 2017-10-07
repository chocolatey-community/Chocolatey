InModuleScope Chocolatey {
    Describe Install-ChocolateySoftware {

        Mock Get-Command -MockWith { Get-Command Write-Output }
        Mock Get-ChocolateyFeature -MockWith {
            'MyChocoFeature'
        }
        Mock Get-ChocolateyDefaultArgument -MockWith { 'TestArgument' }
        
        Context 'Default' {
            It 'Should call Get-Command' {
                $null = Disable-ChocolateyFeature -Name 'TestFeature'
                {Assert-MockCalled Get-Command} | Should not Throw
            }
            It 'Should Call Get-ChocolateyFeature' {
                $null = Disable-ChocolateyFeature -Name 'TestFeature'
                {Assert-MockCalled Get-ChocolateyFeature} | Should not Throw
            }
        }
    }
}