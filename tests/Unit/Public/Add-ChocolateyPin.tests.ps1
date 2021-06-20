InModuleScope Chocolatey {

    Describe "Add-ChocolateyPin" {

        Mock -CommandName Add-ChocolateyPin -MockWith {
            $properties = @{
                Name    = 'TestPackage'
                Version = '1.0.0'
            }

            return (New-Object -TypeName PSObject -Property $properties)
        }

        $results = Add-ChocolateyPin -Name 'TestPackage'

        It 'Should return an PSCustomObject' {
            $results.GetType().Name | Should -Be 'PSCustomObject'
        }

        It 'Should return a Package with name TestPackage' {
            $results.Name | Should -Be 'TestPackage'
        }

        It 'Should return a Version' {
            $results.Version | Should -Be '1.0.0'
        }
    }
}