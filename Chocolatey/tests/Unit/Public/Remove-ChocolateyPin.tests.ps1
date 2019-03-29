InModuleScope Chocolatey {
    Describe Remove-ChocolateyPin {

        Mock Get-Command -MockWith { Get-Command Write-Output } -ParameterFilter {$Name -eq 'choco.exe'}
        Mock Get-ChocolateyPackage -MockWith {
            'MyChocoPin'
        }
        Mock Get-ChocolateyDefaultArgument -MockWith { 'TestArgument' }

        Context 'Default' {

            It 'Should call Get-Command' {
                $null = Remove-ChocolateyPin -Name 'TestPackage'
                {Assert-MockCalled Get-Command} | Should not Throw
            }

            It 'Should call Get-ChocolateyPackage' {
                $null = Disable-ChocolateyPackage -Name 'TestPackage'
                {Assert-MockCalled Get-ChocolateyPackage} | Should not Throw
            }

            It 'Should not return value' {
                $return = Remove-ChocolateyPin -Name 'TestPackage'
                $return | Should BeNullOrEmpty
            }
        }
    }
}