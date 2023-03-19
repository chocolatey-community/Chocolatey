BeforeAll {
    $script:moduleName = 'Chocolatey'

    # If the module is not found, run the build task 'noop'.
    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        # Redirect all streams to $null, except the error stream (stream 2)
        & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    # Re-import the module using force to get any code changes between runs.
    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

BeforeDiscovery {
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
}

Describe Compare-SemVerVersion {
    Context 'Default' {

        It 'Should ensure <RefVersion> <expectedResult> <DiffVersion>' -TestCases $TestCases {
            InModuleScope -ScriptBlock { Compare-SemVerVersion -ReferenceVersion $RefVersion -DifferenceVersion $DiffVersion } -Parameters @{RefVersion = $RefVersion; DiffVersion = $DiffVersion } | Should -Be $expectedResult
        }
    }
}
