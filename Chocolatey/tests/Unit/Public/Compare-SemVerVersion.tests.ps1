InModuleScope Chocolatey {
    Describe Compare-SemVerVersion {

        Context 'Default' {
            

            It 'Should be fine' {
                $true | Should be $true
            }
        }
    }
}