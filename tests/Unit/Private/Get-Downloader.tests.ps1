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

Describe Get-Downloader {

    Context 'Default' {
        BeforeAll {
            $result = InModuleScope -ScriptBlock {Get-Downloader -url 'https://chocolatey.org/api/v2'}
        }

        It 'Should Return a downloader object' {
            $result | Should -not -BeNullOrEmpty
        }

        It 'Should be of type System.Net.WebClient' {
            $result | should -BeOfType [System.Net.WebClient]
        }
    }
}
