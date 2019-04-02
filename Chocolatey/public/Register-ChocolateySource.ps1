<#
.SYNOPSIS
    Register a new Chocolatey source or edit an existing one.

.DESCRIPTION
    Chocolatey will allow you to interact with sources.
    You can register a new source, whether internal or external with some source
    specific settings such as proxy.

.PARAMETER Name
    Name - the name of the source. Required with some actions. Defaults to empty.

.PARAMETER Source
    Source - The source. This can be a folder/file share or an http location.
    If it is a url, it will be a location you can go to in a browser and
    it returns OData with something that says Packages in the browser,
    similar to what you see when you go to https://chocolatey.org/api/v2/.
    Defaults to empty.

.PARAMETER Disabled
    Allow the source to be registered but disabled.

.PARAMETER BypassProxy
    Bypass Proxy - Should this source explicitly bypass any explicitly or
    system configured proxies? Defaults to false. Available in 0.10.4+.

.PARAMETER SelfService
    Allow Self-Service - Should this source be allowed to be used with self-
    service? Requires business edition (v1.10.0+) with feature
    'useBackgroundServiceWithSelfServiceSourcesOnly' turned on. Defaults to
    false. Available in 0.10.4+.

.PARAMETER Priority
    Priority - The priority order of this source as compared to other
    sources, lower is better. Defaults to 0 (no priority). All priorities
    above 0 will be evaluated first, then zero-based values will be
    evaluated in config file order. Available in 0.9.9.9+.

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

.PARAMETER KeyUser
    API Key User for the source being registered.

.PARAMETER Key
    API key for the source (too long in C4B to be passed as credentials)

.EXAMPLE
    Register-ChocolateySource -Name MyNuget -Source https://proget/nuget/choco

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsSource
#>
function Register-ChocolateySource {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory
            ,ValueFromPipelineByPropertyName
        )]
        [System.String]
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
        [System.String]
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
            Throw "Chocolatey Software not found."
        }

        if (!$PSBoundParameters.containskey('Disabled')){
            $null = $PSBoundParameters.add('Disabled',$Disabled)
        }
        if (!$PSBoundParameters.containskey('SelfService')){
            $null = $PSBoundParameters.add('SelfService',$SelfService)
        }
        if (!$PSBoundParameters.containskey('BypassProxy')){
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