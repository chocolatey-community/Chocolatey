<#
.SYNOPSIS
    Test if the Chocolatey Software is installed.

.DESCRIPTION
    To test whether the Chocolatey Software is installed, it first look for the Command choco.exe.
    It then check if it's installed in the InstallDir path, if provided.

.PARAMETER InstallDir
    To ensure the software is installed in the given directory. If not specified,
    it will only test if the commadn choco.exe is available.

.EXAMPLE
    Test-ChocolateyInstall #Test whether the Chocolatey Software is installed

.NOTES
General notes
#>
function Test-ChocolateyInstall
{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $InstallDir
    )

    Write-Verbose "Loading machine Path Environment variable into session."
    $envPath = [Environment]::GetEnvironmentVariable('Path','Machine')
    [Environment]::SetEnvironmentVariable($envPath,'Process')

    if ($InstallDir) {
        $InstallDir = (Resolve-Path $InstallDir -ErrorAction Stop).Path
    }

    if ($chocoCmd = get-command choco.exe -CommandType Application -ErrorAction SilentlyContinue)
    {
        if (
            !$InstallDir -or
            $chocoCmd.Path -match [regex]::Escape($InstallDir)
        )
        {
            Write-Verbose ('Chocolatey Software found in {0}' -f $chocoCmd.Path)
            return $true
        }
        else
        {
            Write-Verbose (
                'Chocolatey Software not installed in {0}`n but in {1}' -f $InstallDir,$chocoCmd.Path
            )
            return $false
        }
    }
    else {
        Write-Verbose "Chocolatey Software not found."
        return $false
    }
}