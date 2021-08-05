<#
.SYNOPSIS
    Test whether a package is set, enabled or not found

.DESCRIPTION
    This command allows you to test the values of a pinned package.

.PARAMETER Name
    Name of the Package to verify

.PARAMETER Version
    Test if the Package version provided matches with the one set on the config file.

.EXAMPLE
    Test-ChocolateyPin -Name PackageName -Version ''

.NOTES
    https://chocolatey.org/docs/commands-pin
#>
function Test-ChocolateyPin
{
    [CmdletBinding(
        DefaultParameterSetName = 'Set'
    )]
    [OutputType([Bool])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Version
    )

    process
    {
        if (-not (Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue))
        {
            throw "Chocolatey Software not found."
        }

        if (!($Setting = Get-ChocolateyPin -Name $Name))
        {
            Write-Verbose -Message "The Pin for the Chocolatey Package '$Name' cannot be found."
            return $false
        }

        $Version = $ExecutionContext.InvokeCommand.ExpandString($Version).TrimEnd(@('/', '\'))
        if ([string]$Setting.Version -eq $Version)
        {
            Write-Verbose ("The Pin for the Chocolatey Package '{0}' is set to '{1}' as expected." -f $Name, $Version)
            return $true
        }
        else
        {
            Write-Verbose ("The Pin for the Chocolatey Package '{0}' is NOT set to '{1}' as expected." -f $Name, $Setting.Version)
            return $False
        }
    }
}
