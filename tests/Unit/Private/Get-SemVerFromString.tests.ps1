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
    $TestCases =@(
        @{ StringVersion = '0.2.3.5-pre1+42'; ExpectedResult = @{version = [System.Version]'0.2.3.5'; Metadata = '42'; PreRelease = 'pre1'}  }
        @{ StringVersion = '0.2.3.5-Alpha.123.456'; ExpectedResult = @{version = [System.Version]'0.2.3.5'; Metadata = $null; PreRelease = 'Alpha.123.456'}  }
        @{ StringVersion = '0.2.3.5+42'; ExpectedResult = @{version = [System.Version]'0.2.3.5'; Metadata = '42'; PreRelease = $null}  }
        @{ StringVersion = '1.2'; ExpectedResult = @{version = [System.Version]'1.2'; Metadata = $null; PreRelease = $null}  }
    )
}

Describe Get-SemVerFromString {
    Context 'Default' {

        It 'Version <StringVersion> parses correctly' -TestCases $TestCases {

            $parsedVersion = InModuleScope -ScriptBlock { Get-SemVerFromString -VersionString $StringVersion } -Parameters @{StringVersion = $StringVersion}
            $parsedVersion.version    | Should -Be $expectedResult.version
            $parsedVersion.Metadata   | Should -Be $expectedResult.Metadata
            $parsedVersion.Prerelease | Should -Be $expectedResult.Prerelease
        }
    }
}
