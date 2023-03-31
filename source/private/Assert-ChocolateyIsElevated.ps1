<#
.SYNOPSIS
    Make sure the current process is running elevated for Chocolatey.

.DESCRIPTION
    This command throws if the process is not running elevated.
    This is useful when running in a default value of a switch parameter
    to validate either that the running process is elevated, or that
    the user wants to run non elevated anyway by toggling the switch.

.EXAMPLE
    [Parameter(DontShow)]
    [switch]
    $RunNonElevated = $(Assert-ChocolateyIsElevated)

.NOTES
    This is only for commands that change the system and needs Elevated permissions.
#>
function Assert-ChocolateyIsElevated
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        #
    )

    if ([Security.Principal.WindowsPrincipal]::New([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Write-Verbose -Message 'This process is running elevated.'
    }
    else
    {
        throw 'This command must be ran elevated.'
    }
}
