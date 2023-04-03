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
        throw 'The chocolatey install Machine environment variable couldn''t be found.'
    }

    return $chocoInstallPath
}
