
<#
.SYNOPSIS
    Uninstalls a Chocolatey package or a list of packages.

.DESCRIPTION
    Once the Chocolatey Software has been installed (see Install-ChocolateySoftware) this command
    allows you to uninstall Software installed by Chocolatey,
    or synced from Add-remove program (Business edition).

.PARAMETER Name
    Package Name to uninstall, either from a configured source, a specified one such as a folder,
    or the current directory '.'

.PARAMETER Version
    Version - A specific version to install.

.PARAMETER Source
    Source - The source to find the package(s) to install. Special sources
    include: ruby, webpi, cygwin, windowsfeatures, and python. To specify
    more than one source, pass it with a semi-colon separating the values (-
    e.g. "'source1;source2'"). Defaults to default feeds.

.PARAMETER Credential
    Credential used with authenticated feeds. Defaults to empty.

.PARAMETER Force
    Force - force the behavior. Do not use force during normal operation -
    it subverts some of the smart behavior for commands.

.PARAMETER CacheLocation
    CacheLocation - Location for download cache, defaults to %TEMP% or value
    in chocolatey.config file.

.PARAMETER NoProgress
    Do Not Show Progress - Do not show download progress percentages.
    Available in 0.10.4+.

.PARAMETER AcceptLicense
    AcceptLicense - Accept license dialogs automatically. Reserved for future use.

.PARAMETER Timeout
    CommandExecutionTimeout (in seconds) - The time to allow a command to
    finish before timing out. Overrides the default execution timeout in the
    configuration of 2700 seconds. '0' for infinite starting in 0.10.4.

.PARAMETER UninstallArguments
    UninstallArguments - Uninstall Arguments to pass to the native installer
    in the package. Defaults to unspecified.

.PARAMETER OverrideArguments
    OverrideArguments - Should uninstall arguments be used exclusively
    without appending to current package passed arguments? Defaults to false.

.PARAMETER NotSilent
    NotSilent - Do not uninstall this silently. Defaults to false.

.PARAMETER ApplyArgsToDependencies
    Apply Install Arguments To Dependencies  - Should install arguments be
    applied to dependent packages? Defaults to false.

.PARAMETER IgnoreDependencies
    IgnoreDependencies - Ignore dependencies when installing package(s).
    Defaults to false.

.PARAMETER ForceDependencies
    RemoveDependencies - Uninstall dependencies when uninstalling package(s).
    Defaults to false.

.PARAMETER SkipPowerShell
    Skip Powershell - Do not run chocolateyUninstall.ps1. Defaults to false.

.PARAMETER ignorePackageCodes
    IgnorePackageExitCodes - Exit with a 0 for success and 1 for non-succes-s,
    no matter what package scripts provide for exit codes. Overrides the
    default feature 'usePackageExitCodes' set to 'True'. Available in 0.9.10+.

.PARAMETER UsePackageCodes
    UsePackageExitCodes - Package scripts can provide exit codes. Use those
    for choco's exit code when non-zero (this value can come from a
    dependency package). Chocolatey defines valid exit codes as 0, 1605,
    1614, 1641, 3010. Overrides the default feature 'usePackageExitCodes'
    set to 'True'.
    Available in 0.9.10+.

.PARAMETER StopOnFirstFailure
    Stop On First Package Failure - stop running install, upgrade or
    uninstall on first package failure instead of continuing with others.
    Overrides the default feature 'stopOnFirstPackageFailure' set to 'False'.
    Available in 0.10.4+.

.PARAMETER AutoUninstaller
    UseAutoUninstaller - Use auto uninstaller service when uninstalling.
    Overrides the default feature 'autoUninstaller' set to 'True'.
    Available in 0.9.10+.

.PARAMETER SkipAutoUninstaller
    SkipAutoUninstaller - Skip auto uninstaller service when uninstalling.
    Overrides the default feature 'autoUninstaller' set to 'True'. Available
    in 0.9.10+.

.PARAMETER FailOnAutouninstaller
    FailOnAutoUninstaller - Fail the package uninstall if the auto
    uninstaller reports and error. Overrides the default feature
    'failOnAutoUninstaller' set to 'False'. Available in 0.9.10+.

.PARAMETER IgnoreAutoUninstallerFailure
    Ignore Auto Uninstaller Failure - Do not fail the package if auto
    uninstaller reports an error. Overrides the default feature
    'failOnAutoUninstaller' set to 'False'. Available in 0.9.10+.

.EXAMPLE
    Uninstall-ChocolateyPackage -Name Putty

.NOTES
    https://github.com/chocolatey/choco/wiki/Commandsuninstall
#>
function Uninstall-ChocolateyPackage
{
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]
    param (
        [Parameter(
            Mandatory = $true
            , ValueFromPipeline
            , ValueFromPipelineByPropertyName
        )]
        [System.String[]]
        $Name,

        [Parameter(
            , ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Version,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        $Source,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [PSCredential]
        $Credential,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $Force,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [System.String]
        $CacheLocation,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $NoProgress,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $AcceptLicense,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [int]
        $Timeout,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [System.String]
        $UninstallArguments,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $OverrideArguments,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $NotSilent,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $ApplyArgsToDependencies,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $IgnoreDependencies,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $ForceDependencies,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $SkipPowerShell,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $ignorePackageCodes,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $UsePackageCodes,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $StopOnFirstFailure,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $AutoUninstaller,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $SkipAutoUninstaller,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $FailOnAutouninstaller,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $IgnoreAutoUninstallerFailure
    )

    begin
    {
        $null = $PSboundParameters.remove('Name')
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue))
        {
            throw "Chocolatey Software not found."
        }
        $CachePath = [io.path]::Combine($Env:ChocolateyInstall, 'cache', 'GetChocolateyPackageCache.xml')
        if ( (Test-Path $CachePath))
        {
            $null = Remove-Item -Path $CachePath -ErrorAction 'SilentlyContinue' -Confirm:$false
        }
    }
    process
    {
        foreach ($PackageName in $Name)
        {
            $ChocoArguments = @('uninstall', $PackageName)
            $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
            Write-Verbose "choco $($ChocoArguments -join ' ')"

            if ($PSCmdlet.ShouldProcess($PackageName, "Uninstall"))
            {
                #Impact confirmed, go choco go!
                $ChocoArguments += '-y'
                &$chocoCmd $ChocoArguments | Write-Verbose
            }
        }
    }
}
