InModuleScope Chocolatey {
    Describe Get-ChocolateyDefaultArgument {

        Context 'Default' {
            It 'Should return a string' {
                $result = Get-ChocolateyDefaultArgument -key 'value'
                $result | Should be '--password="value"'
            }
        }
    }
}