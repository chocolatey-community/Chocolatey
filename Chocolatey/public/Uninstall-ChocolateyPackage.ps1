function Uninstall-ChocolateyPackage {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    Param(
        [Parameter(
            Mandatory
            ,ValueFromPipeline
            ,ValueFromPipelineByPropertyName
        )]
        [String[]]
        $Name,

        [Parameter(
            ,ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [String]
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
        [switch]
        $NoProgress,

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
        $x86,

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
        $IgnoreAutoUninstallerFailure
    )

    begin {
        $null = $PSboundParameters.remove('Name')
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found"
        }
    }
    Process {
        foreach ($PackageName in $Name) {
            $ChocoArguments = @('uninstall',$PackageName)
            $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
            Write-Verbose "choco $($ChocoArguments -join ' ')"

            if ($PSCmdlet.ShouldProcess($PackageName,"Upgrade")) {
                #Impact confirmed, go choco go!
                $ChocoArguments += '-y'
                &$chocoCmd $ChocoArguments | Write-Verbose
            }
        }
    }
}