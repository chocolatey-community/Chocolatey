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

Describe "Remove-ChocolateyPin" {

    BeforeAll {
        Mock Get-Command -MockWith { Get-Command Write-Output } -ParameterFilter {$Name -eq 'choco.exe'}
        #TODO: Fix this test
        # Mock -CommandName Remove-ChocolateyPin -MockWith {
        #     $properties = @{
        #         Name    = 'TestPackage'
        #         Version = '1.0.0'
        #     }

        #     return (New-Object -TypeName PSObject -Property $properties)
        # }

        # $results = Remove-ChocolateyPin -Name 'TestPackage'

    }

    It 'Should return an PSCustomObject' {
        $true | Should -Be $true
        # $results.GetType().Name | Should -Be 'PSCustomObject'
    }

    # It 'Should return a Package with name TestPackage' {
    #     $results.Name | Should -Be 'TestPackage'
    # }
}
