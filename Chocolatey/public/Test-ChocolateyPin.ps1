<#
.SYNOPSIS
    Test Whether a package is set, enabled or not found

.DESCRIPTION
    This command allows you to test the values of a pinned package.

.PARAMETER Name
    Name of the PAckage to verify

.PARAMETER Version
    Test if the Package version provided matches with the one set on the config file.

.EXAMPLE
    Test-ChocolateyPin -Name SettingName -Version ''

.NOTES
    https://chocolatey.org/docs/commands-pin
#>
function Test-ChocolateyPin {
    [CmdletBinding(
        DefaultParameterSetName = 'Set'
    )]
    [OutputType([Bool])]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [System.String]
        $Name,

        [System.String]
        $Version
    )

    Process {
        if (-not (Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found."
        }

        if (!($Setting = Get-ChocolateyPin -Name $Name)) {
            Write-Warning "Chocolatey Package $Name cannot be found."
            return $false
        }

        $Version = $ExecutionContext.InvokeCommand.ExpandString($Version).TrimEnd(@('/','\'))
        if ([string]$Name.value -eq $Value) {
            Write-Verbose ("The Chocolatey Pin {0} is set to '{1}' as expected." -f $Name,$Version)
            return $true
        }
        else {
            Write-Verbose ("The Chocolatey Pin {0} is NOT set to '{1}' as expected." -f $Name,$Setting.Version)
            return $False
        }
    }
}