
<#
.SYNOPSIS
    Attempts to remove the Chocolatey Software form the system.

.DESCRIPTION
    This command attempts to clean the system from the Chocolatey Software files.
    It first look into the provided $InstallDir, or in the $Env:ChocolateyInstall if not provided.
    If the $InstallDir provided is $null or empty, it will attempts to find the Chocolatey folder
    from the choco.exe command path.
    If no choco.exe is found under the $InstallDir, it will fail to uninstall.
    This command also remove the $InstallDir from the Path.

.PARAMETER InstallDir
    Installation Directory to remove Chocolatey from. Default looks up in $Env:ChocolateyInstall
    Or, if specified with an empty/$null value, tries to find from the choco.exe path.

.PARAMETER RunNonElevated
    Throws if the process is not running elevated. use -RunNonElevated if you really want to run
    even if the current shell is not elevated.

.EXAMPLE
    Uninstall-Chocolatey -InstallDir ''
    Will uninstall Chocolatey from the location of Choco.exe if found from $Env:PATH
#>
function Uninstall-Chocolatey
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.String]
        $InstallDir = $(Get-ChocolateyInstallPath -ErrorAction 'Ignore'),

        [Parameter(DontShow)]
        [switch]
        $RunNonElevated = $(Assert-ChocolateyIsElevated)
    )

    process
    {
        #If InstallDir is empty or null, select from the choco.exe if available
        if (-not $InstallDir)
        {
            Write-Debug -Message "Attempting to find the choco.exe command."
            $chocoCmd = @(Get-Command 'choco.exe' -CommandType 'Application' -ErrorAction 'SilentlyContinue')[0]
            #Install dir is where choco.exe is found minus \bin subfolder
            if (-not ($chocoCmd -and ($chocoBin = Split-Path -Parent $chocoCmd.Path -ErrorAction SilentlyContinue)))
            {
                Write-Warning -Message "Could not find Chocolatey Software Install Folder."
                return
            }
            else
            {
                Write-Debug "Resolving $chocoBin\.."
                $InstallDir = (Resolve-Path ([io.path]::combine($chocoBin, '..'))).Path
            }
        }

        Write-Verbose -Message "Chocolatey Installation Folder is $InstallDir"
        $chocoFiles = @('choco.exe', 'chocolatey.exe', 'cinst.exe', 'cuninst.exe', 'clist.exe', 'cpack.exe', 'cpush.exe',
            'cver.exe', 'cup.exe').Foreach{ $_; "$_.old" } #ensure the .old are also removed

        #If Install dir does not have a choco.exe, do nothing as it could delete unwanted files
        if
        (
            [string]::IsNullOrEmpty($InstallDir) -or
            -not ((Test-Path -Path $InstallDir) -and (Test-Path -Path "$InstallDir\Choco.exe"))
        )
        {
            Write-Warning -Message 'Chocolatey Installation Folder Not found.'
            return
        }

        #all files under $InstallDir
        # Except those in $InstallDir\lib unless $_.Basename -in $chocoFiles
        # Except those in $installDir\bin unless $_.Basename -in $chocoFiles
        $FilesToRemove = Get-ChildItem $InstallDir -Recurse | Where-Object {
            -not (
                (
                    $_.FullName -match [regex]::escape([io.path]::combine($InstallDir, 'lib')) -or
                    $_.FullName -match [regex]::escape([io.path]::combine($InstallDir, 'bin'))
                ) -and
                $_.Name -notin $chocofiles
            )
        }

        Write-Debug ($FilesToRemove -join "`r`n>>  ")

        if ($Pscmdlet.ShouldProcess('Chocofiles'))
        {
            $FilesToRemove | Sort-Object -Descending FullName | remove-item -Force -recurse -ErrorAction 'SilentlyContinue' -Confirm:$false
        }

        Write-Verbose -Message "Removing $InstallDir from the Path and the ChocolateyInstall Environment variable."
        [Environment]::SetEnvironmentVariable('ChocolateyInstall', $null, 'Machine')
        [Environment]::SetEnvironmentVariable('ChocolateyInstall', $null, 'Process')
        $AllPaths = [Environment]::GetEnvironmentVariable('Path', 'machine').split(';').where{
            ![string]::IsNullOrEmpty($_) -and
            $_ -notmatch "^$([regex]::Escape($InstallDir))\\bin$"
        } | Select-Object -unique

        Write-Debug 'Reset the machine Path without choco (and dedupe/no null).'
        Write-Debug ($AllPaths | Format-Table | Out-String)
        [Environment]::SetEnvironmentVariable('Path', ($AllPaths -Join ';'), 'Machine')

        #refresh after uninstall
        $envPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
        [Environment]::SetEnvironmentVariable($EnvPath, 'process')
        Write-Verbose 'Unistallation complete'
    }
}
