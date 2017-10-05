function Test-ChocolateyInstall
{
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $InstallDir
    )

    Write-Verbose "Loading machine Path Environment variable into session"
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    if($InstallDir) {
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