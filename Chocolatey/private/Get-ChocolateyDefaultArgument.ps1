<#
.SYNOPSIS
Transforms parameters Key/value into choco.exe Parameters.

.DESCRIPTION
This private command allows to pass parameters and it returns
an array of parameters to be used with the choco.exe command.
No validation is done at this level, it should be handled
by the Commands leveraging this function.

.PARAMETER Name
Name of the element being targeted (can be source, feature, package and so on).

.PARAMETER Value
The value of the config setting. Required with some Actions.
Defaults to empty.

.PARAMETER Source
Source uri (whether local or remote)

.PARAMETER Disabled
Specify whethere the element targeted should be disabled or enabled (by default).

.PARAMETER BypassProxy
Bypass the proxy for fetching packages on a feed.

.PARAMETER SelfService
Specify if the source is, can or should be used for self service.

.PARAMETER NotBroken
Filter out the packages that are reported broken.

.PARAMETER AllVersions
List all version available.

.PARAMETER Priority
Priority of the feed, default to 0

.PARAMETER Credential
Credential to authenticate to the source feed.

.PARAMETER ProxyCredential
Credential for the Proxy.

.PARAMETER Force
Force the action being targeted.

.PARAMETER CacheLocation
Location where the download will be cached.

.PARAMETER InstallArguments
Arguments to pass to the Installer (Not Package args)

.PARAMETER InstallArgumentsSensitive
Arguments to pass to the Installer that should be obfuscated from log and output.

.PARAMETER PackageParameters
PackageParameters - Parameters to pass to the package, that should be handled by the ChocolateyInstall.ps1

.PARAMETER PackageParametersSensitive
Arguments to pass to the Package that should be obfuscated from log and output.

.PARAMETER OverrideArguments
Should install arguments be used exclusively without appending to current package passed arguments

.PARAMETER NotSilent
Do not install this silently. Defaults to false.

.PARAMETER ApplyArgsToDependencies
Apply Install Arguments To Dependencies  - Should install arguments be
applied to dependent packages? Defaults to false

.PARAMETER AllowDowngrade
Should an attempt at downgrading be allowed? Defaults to false.

.PARAMETER SideBySide
AllowMultipleVersions - Should multiple versions of a package be installed?

.PARAMETER IgnoreDependencies
IgnoreDependencies - Ignore dependencies when installing package(s).

.PARAMETER NoProgress
Do Not Show Progress - Do not show download progress percentages

.PARAMETER ForceDependencies
Force dependencies to be reinstalled when force
installing package(s). Must be used in conjunction with --force.
Defaults to false.

.PARAMETER SkipPowerShell
Skip Powershell - Do not run chocolateyInstall.ps1. Defaults to false.

.PARAMETER IgnoreChecksum
IgnoreChecksums - Ignore checksums provided by the package. Overrides
the default feature 'checksumFiles' set to 'True'.

.PARAMETER AllowEmptyChecksum
Allow Empty Checksums - Allow packages to have empty/missing checksums
for downloaded resources from non-secure locations (HTTP, FTP). Use this
switch is not recommended if using sources that download resources from
the internet. Overrides the default feature 'allowEmptyChecksums' set to
'False'. Available in 0.10.0+.

.PARAMETER ignorePackageCodes
IgnorePackageExitCodes - Exit with a 0 for success and 1 for non-success,
no matter what package scripts provide for exit codes. Overrides the
default feature 'usePackageExitCodes' set to 'True'. Available in 0.-
9.10+.

.PARAMETER UsePackageCodes
UsePackageExitCodes - Package scripts can provide exit codes. Use those
for choco's exit code when non-zero (this value can come from a
dependency package). Chocolatey defines valid exit codes as 0, 1605,
1614, 1641, 3010.  Overrides the default feature 'usePackageExitCodes'
set to 'True'. Available in 0.9.10+.

.PARAMETER StopOnFirstFailure
Stop On First Package Failure - stop running install, upgrade or
uninstall on first package failure instead of continuing with others.
Overrides the default feature 'stopOnFirstPackageFailure' set to 'False-
'. Available in 0.10.4+.

.PARAMETER SkipCache
Skip Download Cache - Use the original download even if a private CDN
cache is available for a package. Overrides the default feature
'downloadCache' set to 'True'. Available in 0.9.10+. [Licensed editions](https://chocolatey.org/compare)
only. See https://chocolatey.org/docs/features-private-cdn

.PARAMETER UseDownloadCache
Use Download Cache - Use private CDN cache if available for a package.
Overrides the default feature 'downloadCache' set to 'True'. Available
in 0.9.10+. [Licensed editions](https://chocolatey.org/compare) only. See https://chocolate-
y.org/docs/features-private-cdn

.PARAMETER SkipVirusCheck
Skip Virus Check - Skip the virus check for downloaded files on this run.
 Overrides the default feature 'virusCheck' set to 'True'. Available
in 0.9.10+. [Licensed editions](https://chocolatey.org/compare) only.
See https://chocolatey.org/docs/features-virus-check

.PARAMETER VirusCheck
Virus Check - check downloaded files for viruses. Overrides the default
feature 'virusCheck' set to 'True'. Available in 0.9.10+. Licensed
editions only. See https://chocolatey.org/docs/features-virus-check

.PARAMETER VirusPositive
Virus Check Minimum Scan Result Positives - the minimum number of scan
result positives required to flag a package. Used when virusScannerType
is VirusTotal. Overrides the default configuration value
'virusCheckMinimumPositives' set to '5'. Available in 0.9.10+. Licensed
editions only. See https://chocolatey.org/docs/features-virus-check

.PARAMETER OrderByPopularity
Order the community packages (chocolatey.org) by popularity.

.PARAMETER Version
Version - A specific version to install. Defaults to unspecified.

.PARAMETER LocalOnly
LocalOnly - Only search against local machine items.

.PARAMETER IdOnly
 Id Only - Only return Package Ids in the list results. Available in 0.10.6+.

.PARAMETER Prerelease
Prerelease - Include Prereleases? Defaults to false.

.PARAMETER ApprovedOnly
ApprovedOnly - Only return approved packages - this option will filter
out results not from the [community repository](https://chocolatey.org/packages). Available in 0.9.10+.

.PARAMETER IncludePrograms
IncludePrograms - Used in conjunction with LocalOnly, filters out apps
chocolatey has listed as packages and includes those in the list.
Defaults to false.

.PARAMETER ByIdOnly
ByIdOnly - Only return packages where the id contains the search filter.
Available in 0.9.10+.

.PARAMETER IdStartsWith
IdStartsWith - Only return packages where the id starts with the search
filter. Available in 0.9.10+.

.PARAMETER Exact
Exact - Only return packages with this exact name. Available in 0.9.10+.

.PARAMETER x86
Force the x86 packages on x64 machines.

.PARAMETER AcceptLicense
AcceptLicense - Accept license dialogs automatically.
Reserved for future use.

.PARAMETER Timeout
CommandExecutionTimeout (in seconds) - The time to allow a command to
finish before timing out. Overrides the default execution timeout in the
configuration of 2700 seconds. '0' for infinite starting in 0.10.4.

.PARAMETER UseRememberedArguments
Use Remembered Options for Upgrade - use the arguments and options used
during install for upgrade. Does not override arguments being passed at
runtime. Overrides the default feature
'useRememberedArgumentsForUpgrades' set to 'False'. Available in 0.10.4+.

.PARAMETER IgnoreRememberedArguments
Ignore Remembered Options for Upgrade - ignore the arguments and options
used during install for upgrade. Overrides the default feature
'useRememberedArgumentsForUpgrades' set to 'False'. Available in 0.10.4+.

.PARAMETER ExcludePrerelease
Exclude Prerelease - Should prerelease be ignored for upgrades? Will be
ignored if you pass `--pre`. Available in 0.10.4+.

.PARAMETER AutoUninstaller
UseAutoUninstaller - Use auto uninstaller service when uninstalling.
Overrides the default feature 'autoUninstaller' set to 'True'. Available
in 0.9.10+.

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

.PARAMETER KeyUser
User - used with authenticated feeds. Defaults to empty.

.PARAMETER Key
Password - the user's password to the source. Encrypted in chocolatey.config file.

.EXAMPLE
Get-ChocolateyDefaultArguments @PSBoundparameters

#>
function Get-ChocolateyDefaultArgument {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(
        SupportsShouldProcess=$true
        ,ConfirmImpact="High"
    )]
    Param(
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [String]
        $Name,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        $Source,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $Disabled,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        $Value,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $BypassProxy,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $SelfService,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $NotBroken,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $AllVersions,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [int]
        $Priority = 0,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [PSCredential]
        $Credential,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [PSCredential]
        $ProxyCredential,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $Force,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [String]
        $CacheLocation,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [String]
        $InstallArguments,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [String]
        $InstallArgumentsSensitive,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [String]
        $PackageParameters,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [String]
        $PackageParametersSensitive,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $OverrideArguments,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $NotSilent,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $ApplyArgsToDependencies,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $AllowDowngrade,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $SideBySide,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $IgnoreDependencies,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $NoProgress,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $ForceDependencies,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $SkipPowerShell,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $IgnoreChecksum,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $AllowEmptyChecksum,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $ignorePackageCodes,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $UsePackageCodes,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $StopOnFirstFailure,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $SkipCache,


        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $UseDownloadCache,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $SkipVirusCheck,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $VirusCheck,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [int]
        $VirusPositive,

        [Parameter(
            ,ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [Switch]
        $OrderByPopularity,

        [Parameter(
            ,ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Version,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $LocalOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $IdOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $Prerelease,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $ApprovedOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $IncludePrograms,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $ByIdOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $IdStartsWith,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $Exact,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $x86,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $AcceptLicense,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [int]
        $Timeout,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $UseRememberedArguments,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $IgnoreRememberedArguments,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $ExcludePrerelease,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $AutoUninstaller,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $SkipAutoUninstaller,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $FailOnAutouninstaller,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $IgnoreAutoUninstallerFailure,

        #To be used when Password is too long (>240 char) like a key
        $KeyUser,
        $Key
    )

    Process {

        $ChocoArguments = switch($PSBoundParameters.Keys) {
            'Value'         { "--value=`"$value`""}
            'Priority'      { if ( $Priority -gt 0) {"--priority=$priority" } }
            'SelfService'   { "--allow-self-service"}
            'Name'          { "--name=`"$Name`"" }
            'Source'        { "-s`"$Source`"" }
            'ByPassProxy'   {  "--bypass-proxy" }
            'CacheLocation' { "--cache-location=`"$CacheLocation`"" }
            'WhatIf'        {  "--whatif"  }
            'cert'          { "--cert=`"$Cert`"" }
            'Force'         {  '--yes'; '--force' }
            'AcceptLicense' { '--accept-license' }
            'Verbose'       { '--verbose'}
            'Debug'         { '--debug'  }
            'NoProgress'    { '--no-progress' }
            'Credential'    {
                if ($Credential.Username) {
                    "--user=`"$($Credential.Username)`""
                }
                if($Credential.GetNetworkCredential().Password) {
                    "--password=`"$($Credential.GetNetworkCredential().Password)`""
                }
            }
            'KeyUser'           { "--user=`"$KeyUser`"" }
            'Key'               { "--password=`"$Key`"" }
            'Timeout'           { "--execution-timeout=$Timeout" }
            'AllowUnofficalBuild'{ "--allow-unofficial-build" }
            'FailOnSTDErr'      { '--fail-on-stderr' }
            'Proxy'             { "--Proxy=`"$Proxy`"" }
            'ProxyCredential'   {
                if ($ProxyCredential.Username) {
                    "--proxy-user=`"$($ProxyCredential.Username)`""
                }
                if($ProxyCredential.GetNetworkCredential().Password) {
                    "--proxy-password=`"$($ProxyCredential.GetNetworkCredential().Password)`""
                }
            }
            'ProxyBypassList'   { "--proxy-bypass-list=`"$($ProxyBypassList -join ',')`"" }
            'ProxyBypassLocal'  { "--proxy-bypass-on-local" }

            #List / Search Parameters
            'ByTagOnly'         { '--by-tag-only' }
            'ByIdOnly'          { '--by-id-only' }
            'LocalOnly'         { '--local-only' }
            'IdStartsWith'      { '--id-starts-with' }
            'ApprovedOnly'      { '--approved-only'}
            'OrderByPopularity' { '--order-by-popularity' }
            'NotBroken'         { '--not-broken' }
            'prerelease'        { '--prerelease' }
            'IncludePrograms'   { '--include-programs'}
            'AllVersions'       { '--all-versions' }
            'Version'           { "--version=`"$version`"" }
            'exact'             { "--exact" }

            #Install Parameters
            'x86'               { "--x86"}
            'OverrideArguments' { '--override-arguments' }
            'NotSilent'         { '--not-silent' }
            'ApplyArgsToDependencies' { '--apply-install-arguments-to-dependencies' }
            'AllowDowngrade'    { '--allow-downgrade' }
            'SideBySide'        { '--side-by-side' }
            'ignoredependencies'{ '--ignore-dependencies' }
            'ForceDependencies' { '--force-dependencies' }
            'SkipPowerShell'    { '--skip-powershell' }
            'IgnoreChecksum'    { '--ignore-checksum' }
            'allowemptychecksum'{ '--allow-empty-checksum' }
            'AllowEmptyChecksumSecure' { '--allow-empty-checksums-secure' }
            'RequireChecksum'   { '--requirechecksum'}
            'Checksum'          { "--download-checksum=`"$Checksum`"" }
            'Checksum64'        { "--download-checksum-x64=`"$CheckSum64`"" }
            'ChecksumType'      { "--download-checksum-type=`"$ChecksumType`""}
            'checksumtype64'    { "--download-checksum-type-x64=`"$Checksumtype64`""}
            'ignorepackagecodes'{ '--ignore-package-exit-codes' }
            'UsePackageExitCodes' { '--use-package-exit-codes' }
            'StopOnFirstFailure'{ '--stop-on-first-failure' }
            'SkipCache'         { '--skip-download-cache' }
            'UseDownloadCache'  { '--use-download-cache'}
            'SkipVirusCheck'    { '--skip-virus-check' }
            'VirusCheck'        { '--virus-check' }
            'VirusPositive'     { "--virus-positives-minimum=`"$VirusPositive`"" }
            'InstallArguments'  { "--install-arguments=`"$InstallArguments`""}
            'InstallArgumentsSensitive' { "--install-arguments-sensitive=`"$InstallArgumentsSensitive`""}
            'PackageParameters' {"--package-parameters=`"$PackageParameters`"" }
            'PackageParametersSensitive' { "--package-parameters-sensitive=`"$PackageParametersSensitive`""}
            'MaxDownloadRate'   { "--maximum-download-bits-per-second=$MaxDownloadRate" }
            'IgnoreRememberedArguments' { '--ignore-remembered-arguments' }
            'UseRememberedArguments' { '--use-remembered-options' }
            'ExcludePrerelease'  { '--exclude-pre' }

            #uninstall package params
            'AutoUninstaller'     { '--use-autouninstaller'  }
            'SkipAutoUninstaller' { '--skip-autouninstaller' }
            'FailOnAutouninstaller' { '--fail-on-autouninstaller' }
            'IgnoreAutoUninstallerFailure' { '--ignore-autouninstaller-failure' }
        }

        return $ChocoArguments
    }
}