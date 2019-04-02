<#
.SYNOPSIS
    Test Whether a feature is disabled, enabled or not found

.DESCRIPTION
    Some feature might not be available in your version or SKU.
    This command allows you to test the state of that feature.

.PARAMETER Name
    Name of the feature to verify

.PARAMETER Disabled
    Test if the feature is disabled, the default is to test if the feature is enabled.

.EXAMPLE
    Test-ChocolateyFeature -Name FeatureName -Disabled

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsFeature
#>
function Test-ChocolateyFeature {
    [CmdletBinding()]
    [outputType([Bool])]
    param(
        [Parameter(
            Mandatory
            ,ValueFromPipelineByPropertyName
        )]
        [Alias('Feature')]
        [System.String]
        $Name,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $Disabled
    )

    Process {
        if (-not (Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found."
        }

        if (!($Feature = Get-ChocolateyFeature -Name $Name)) {
            Write-Warning "Chocolatey Feature $Name cannot be found."
            return $false
        }
        $Feature | Write-Verbose
        if ($Feature.enabled -eq !$Disabled.ToBool()) {
            Write-Verbose ("The Chocolatey Feature {0} is set to {1} as expected." -f $Name,(@('Disabled','Enabled')[([int]$Disabled.ToBool())]))
            return $true
        }
        else {
            Write-Verbose ("The Chocolatey Feature {0} is NOT set to {1} as expected." -f $Name,(@('Disabled','Enabled')[([int]$Disabled.ToBool())]))
            return $False
        }
    }
}