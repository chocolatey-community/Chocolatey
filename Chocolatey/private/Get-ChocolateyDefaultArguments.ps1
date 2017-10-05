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
        $PackageArgumentsSensitive,

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
            'Priority'      { if ( $Priority -gt 0) {"--priority=$priority" } }
            'SelfService'   {  "--allow-self-service"}
            'Name'          { "-n`"$Name`"" }
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
                if ($Username = $Credential.Username) {
                    "--user=`"$Username`""
                }
                if($Password = $Credential.GetNetworkCredential().Password) {
                    "--password=`"$Password`""
                }
            }
            'KeyUser'           { "--user=`"$KeyUser`"" }
            'Key'               { "--password=`"$Key`"" }
            'Timeout'           { "--execution-timeout=$Timeout" }
            'AllowUnofficalBuild'{ "--allow-unofficial-build" }
            'FailOnSTDErr'      { '--fail-on-stderr' }
            'Proxy'             { "--Proxy=`"$Proxy`"" }
            'ProxyCredential'   {
                if ($ProxyUsername = $Credential.Username) {
                    "--proxy-user=`"$ProxyUsername`""
                }
                if($ProxyPassword = $Credential.GetNetworkCredential().Password) {
                    "--proxy-password=`"$ProxyPassword`""
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
            'InstallArguments'  { "--install-arguments=`"$InstallArguments`""}
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
            'InstallArgumentsSensitive' { "--install-arguments-sensitive=`"$InstallArgumentsSensitive`""}
            'PackageArgumentsSensitive' { "--package-arguments-sensitive=`"$PackageArgumentsSensitive`""}
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