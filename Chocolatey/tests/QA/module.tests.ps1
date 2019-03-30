$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$modulePath = Resolve-Path "$here\..\.."
$moduleName = Split-Path -Path $modulePath -Leaf

Describe 'General module control' -Tags 'FunctionalQuality'   {

    It 'Should import without errors' {
        Write-Warning $modulePath.Path
        { Import-Module -Name $modulePath.Path -Force -ErrorAction Stop } | Should -Not -Throw
        Get-Module $moduleName | Should -Not -BeNullOrEmpty
    }

    It 'Should remove without error' {
        { Remove-Module -Name $moduleName -ErrorAction Stop} | Should -not -Throw
        Get-Module $moduleName | Should -beNullOrEmpty
    }
}

#$PrivateFunctions = Get-ChildItem -Path "$modulePath\Private\*.ps1"
#$PublicFunctions =  Get-ChildItem -Path "$modulePath\Public\*.ps1"
$allModuleFunctions = @()
$allModuleFunctions += Get-ChildItem -Path "$modulePath\Private\*.ps1" -ErrorAction SilentlyContinue
$allModuleFunctions += Get-ChildItem -Path "$modulePath\Public\*.ps1" -ErrorAction SilentlyContinue

if (Get-Command Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue) {
    $scriptAnalyzerRules = Get-ScriptAnalyzerRule
}
else {
    if ($ErrorActionPreference -ne 'Stop') {
        Write-Warning "ScriptAnalyzer not found!"
    }
    else {
        Throw "ScriptAnalyzer not found!"
    }
}

foreach ($function in $allModuleFunctions) {
    Describe "Quality for $($function.BaseName)" -Tags 'TestQuality' {
        It "$($function.BaseName) have a unit test" {
            Test-Path "$modulePath\tests\Unit\*\$($function.BaseName).tests.ps1" | Should -be $true
        }

        if ($scriptAnalyzerRules) {
            It "Script Analyzer for $($function.BaseName)" {
                forEach ($scriptAnalyzerRule in $scriptAnalyzerRules) {
                    (Invoke-ScriptAnalyzer -Path $function.FullName -IncludeRule $scriptAnalyzerRule).count |
                         Should -Be 0
                }
            }
        }
    }

    Describe "Help for $($function.BaseName)" -Tags 'helpQuality' {
        $AbstractSyntaxTree = [System.Management.Automation.Language.Parser]::
            ParseInput((Get-Content -raw $function.FullName), [ref]$null, [ref]$null)
            $AstSearchDelegate = { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }
            $ParsedFunction = $AbstractSyntaxTree.FindAll( $AstSearchDelegate,$true )   |
                                Where-Object Name -eq $function.BaseName
        if ($ParsedFunction.GetHelpContent) {
            $FunctionHelp = $ParsedFunction.GetHelpContent()

            It 'Should have a SYNOPSIS' {
                $FunctionHelp.Synopsis | should -not -BeNullOrEmpty
            }

            It 'Should have a Description, with length > 40' {
                $FunctionHelp.Description.Length | Should -beGreaterThan 40
            }

            It 'Should have at least 1 example' {
                $FunctionHelp.Examples.Count | Should -beGreaterThan 0 
                $FunctionHelp.Examples[0] | Should -match ([regex]::Escape($function.BaseName))
                $FunctionHelp.Examples[0].Length | Should -BeGreaterThan ($function.BaseName.Length + 10)
            }

            if ($ParameterNames = $ParsedFunction.Body.ParamBlock.Parameters.name) {
                $parameters = $ParameterNames.VariablePath | ForEach-Object {$_.ToString() }
                foreach ($parameter in $parameters) {
                    It "Should have help for Parameter: $parameter" {
                        $FunctionHelp.Parameters.($parameter.ToUpper())        | Should -Not -BeNullOrEmpty
                        $FunctionHelp.Parameters.($parameter.ToUpper()).Length | Should -BeGreaterThan 25
                    }
                }
            }
        }
    }
}
