InModuleScope Chocolatey {

    Describe "Remove-ChocolateyPin" {

        Mock -CommandName Remove-ChocolateyPin -MockWith {
            $properties = @{
                Name    = 'TestPackage'
                Version = '1.0.0'
            }

            return (New-Object -TypeName PSObject -Property $properties)
        }

        $results = Remove-ChocolateyPin -Name 'TestPackage'

        It 'Should return an PSCustomObject' {
            $results.GetType().Name | Should -Be 'PSCustomObject'
        }

        It 'Should return a Package with name TestPackage' {
            $results.Name | Should -Be 'TestPackage'
        }
    }
}