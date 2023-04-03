
<#
.SYNOPSIS
Gets environment variable ChocolateyInstall from Machine scope.

.DESCRIPTION
This command gets the machine-scoped environment variable 'ChocolateyInstall',
and make sure it's set if the folder is present but variable is not.
If the variable is not set and the choclatey folder can't be found,
the command will write to the error stream.

.EXAMPLE
Get-ChocolateyInstallPath -ErrorAction 'Stop'

#>
function Get-ChocolateyInstallPath
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        #
    )

    $chocoInstallPath = [Environment]::GetEnvironmentVariable('ChocolateyInstall', 'Machine')
    if ([string]::IsNullOrEmpty($chocoPath) -and (Test-Path -Path (Join-Path -Path $env:ProgramData -ChildPath 'Chocolatey')))
    {
        $chocoInstallPath = Join-Path -Path $env:ProgramData -ChildPath 'Chocolatey'
        [Environment]::SetEnvironmentVariable('ChocolateyInstall', $chocoInstallPath, 'Machine')
    }
    elseif (-not [string]::IsNullOrEmpty($chocoInstallPath))
    {
        Write-Debug -Message ('ChocolateyInstall path Machine environmen variable already set to ''{0}''.' -f $chocoInstallPath)
    }
    else
    {
        Write-Error -Message 'The chocolatey install Machine environment variable couldn''t be found.'
    }

    return $chocoInstallPath
}
