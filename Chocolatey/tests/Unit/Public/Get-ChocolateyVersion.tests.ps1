InModuleScope Chocolatey {
    Describe 'Get-ChocolateyVersion' {
        
        Mock Get-Command -MockWith {
            Param()
            { Param() '1.2.3' }
        }

        Context 'Default' {

            It 'Should return version 1.2.3' {
                $version = Get-ChocolateyVersion
                $version | Should be '1.2.3'
            }
        }
        
    }
}