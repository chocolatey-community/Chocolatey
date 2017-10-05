function Register-ChocolateySource {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory
            ,ValueFromPipelineByPropertyName
        )]
        [String]
        $Name,

        [Parameter(
            Mandatory
            ,ValueFromPipelineByPropertyName
        )]
        $Source,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $Disabled = $false,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $BypassProxy = $false,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $SelfService = $false,

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

        #To be used when Password is too long (>240 char) like a key
        $KeyUser,
        $Key

    )

    Process {
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found"
        }

        if(!$PSBoundParameters.containskey('Disabled')){
            $null = $PSBoundParameters.add('Disabled',$Disabled)
        }
        if(!$PSBoundParameters.containskey('SelfService')){
            $null = $PSBoundParameters.add('SelfService',$SelfService)
        }
        if(!$PSBoundParameters.containskey('BypassProxy')){
            $null = $PSBoundParameters.add('BypassProxy',$BypassProxy)
        }

        $ChocoArguments = @('source','add')
        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose "choco $($ChocoArguments -join ' ')"

        &$chocoCmd $ChocoArguments | Write-Verbose

        if ($Disabled) {
            &$chocoCmd @('source','disable',"-n=`"$Name`"") | Write-Verbose
        }
    }
}