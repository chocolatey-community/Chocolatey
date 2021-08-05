InModuleScope Chocolatey {
    Describe 'Get-ChocolateyVersion' {

        Mock Get-Command -MockWith {
            param ()
            { param () '1.2.3' }
        }

        Context 'Default' {

            It 'Should return version 1.2.3' {
                $version = Get-ChocolateyVersion
                $version | Should -Be '1.2.3'
            }
        }

    }
}
