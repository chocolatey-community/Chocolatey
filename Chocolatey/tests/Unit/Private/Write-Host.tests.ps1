InModuleScope Chocolatey {
    Describe Write-Host {
        Mock Write-Verbose -MockWith { }
        Context 'Default' {

            It 'Should Redirect to Write-verbose' {
                { Write-Host 'test' } | Should not throw
                { Assert-MockCalled -CommandName Write-Verbose } | Should not throw
            }
        }
    }
}