InModuleScope Chocolatey {
    Describe Repair-PowerShellOutputRedirectionBug {

        Context 'Default' {

            It 'Should apply the fix silently' {
                { Repair-PowerShellOutputRedirectionBug } | Should -Not Throw
            }
        }
    }
}