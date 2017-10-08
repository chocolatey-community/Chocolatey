InModuleScope Chocolatey {
    Describe Disable-ChocolateySource {

        Mock Get-ChocolateySource -MockWith {
            'MyChocoSource'
        }
        Mock Get-ChocolateyDefaultArgument -MockWith { 'TestArgument' }
        Mock Get-Command -MockWith { Get-Command Write-Output } -ParameterFilter {$Name -eq 'choco.exe'}

        Context 'Default' {

            It 'Should call Get-Command' {
                $null = Disable-ChocolateySource -Name 'TestSource'
                {Assert-MockCalled Get-Command} | Should not Throw
            }
            It 'Should Call Get-ChocolateySource' {
                $null = Disable-ChocolateySource -Name 'TestSource'
                {Assert-MockCalled Get-ChocolateySource} | Should not Throw
            }
            It 'Should not return value' {
                $return = Disable-ChocolateySource -Name 'TestSource'
                $return | Should BeNullOrEmpty
            }
        }
    }
}