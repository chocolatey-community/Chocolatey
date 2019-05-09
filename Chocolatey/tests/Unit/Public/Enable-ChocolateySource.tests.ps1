InModuleScope Chocolatey {
    Describe Enable-ChocolateySource {

        Mock Get-Command -MockWith { Get-Command Write-Output } -ParameterFilter {$Name -eq 'choco.exe'}
        Mock Get-ChocolateySource -MockWith {
            'MyChocoSource'
        }
        Mock Get-ChocolateyDefaultArgument -MockWith { 'TestArgument' }
        
        Context 'Default' {

            It 'Should call Get-Command' {
                $null = Enable-ChocolateySource -Name 'TestSource'
                {Assert-MockCalled Get-Command} | Should not Throw
            }

            It 'Should call Get-ChocolateySource' {
                $null = Enable-ChocolateySource -Name 'TestSource'
                {Assert-MockCalled Get-ChocolateySource} | Should not Throw
            }
            
            It 'Should not return value' {
                $return = Enable-ChocolateySource -Name 'TestSource'
                $return | Should -BeNullOrEmpty
            }
        }
    }
}