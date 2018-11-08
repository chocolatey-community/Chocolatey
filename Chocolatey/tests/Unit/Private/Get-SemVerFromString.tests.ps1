InModuleScope Chocolatey {
    Describe Get-SemVerFromString {

        $TestCases =@(
            @{ StringVersion = '0.2.3.5-pre1+42'; ExpectedResult = @{version = [System.Version]'0.2.3.5'; Metadata = '42'; PreRelease = 'pre1'}  }
            @{ StringVersion = '0.2.3.5-Alpha.123.456'; ExpectedResult = @{version = [System.Version]'0.2.3.5'; Metadata = $null; PreRelease = 'Alpha.123.456'}  }
            @{ StringVersion = '0.2.3.5+42'; ExpectedResult = @{version = [System.Version]'0.2.3.5'; Metadata = '42'; PreRelease = $null}  }
            @{ StringVersion = '1.2'; ExpectedResult = @{version = [System.Version]'1.2'; Metadata = $null; PreRelease = $null}  }
        )
        Context 'Default' {

            It 'Version <StringVersion> parses correctly' -TestCases $TestCases {
                param ($StringVersion, $expectedResult)
                $parsedVersion = Get-SemVerFromString -VersionString $StringVersion
                $parsedVersion.version    | Should -be $expectedResult.version
                $parsedVersion.Metadata   | Should -be $expectedResult.Metadata
                $parsedVersion.Prerelease | Should -be $expectedResult.Prerelease
            }
        }
    }
}