InModuleScope Chocolatey {
    Describe Compare-SemVerVersion {

        $TestCases = @(
            # test as per https://semver.org/#spec-item-11
            @{RefVersion = '1.0.0-alpha'; DiffVersion = '1.0.0-alpha.1'; ExpectedResult = '<'}
            @{RefVersion = '1.0.0-alpha.1'; DiffVersion = '1.0.0-alpha.beta'; ExpectedResult = '<'}
            @{RefVersion = '1.0.0-alpha.beta'; DiffVersion = '1.0.0-beta'; ExpectedResult = '<'}
            @{RefVersion = '1.0.0-beta'; DiffVersion = '1.0.0-beta.2'; ExpectedResult = '<'}
            @{RefVersion = '1.0.0-beta.2'; DiffVersion = '1.0.0-beta.11'; ExpectedResult = '<'}
            @{RefVersion = '1.0.0-beta.11'; DiffVersion = '1.0.0-rc.1'; ExpectedResult = '<'}
            @{RefVersion = '1.0.0-rc.1'; DiffVersion = '1.0.0'; ExpectedResult = '<'}

            # Other tests
            @{RefVersion = '1.2'; DiffVersion = '1.2-rc1'; ExpectedResult = '>'}
            @{RefVersion = '1.2'; DiffVersion = '1.2'; ExpectedResult = '='}
            @{RefVersion = '1.2+metadata'; DiffVersion = '1.2'; ExpectedResult = '='}
            @{RefVersion = '1.2-beta'; DiffVersion = '1.2'; ExpectedResult = '<'}
        )
        Context 'Default' {


            It 'Should ensure <RefVersion> <expectedResult> <DiffVersion>' -TestCases $TestCases {
                Param ($RefVersion, $DiffVersion, $ExpectedResult )
                Compare-SemVerVersion -ReferenceVersion $RefVersion -DifferenceVersion $DiffVersion | Should be $ExpectedResult
            }
        }
    }
}
