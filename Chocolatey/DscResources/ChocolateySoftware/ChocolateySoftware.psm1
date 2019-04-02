function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure

        ,[string]
        $InstallationDirectory
    )
    <#
        ,[string]
        $InstallationDirectory
    #>
    $Env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')

    if ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue) {
        $chocoBin = Split-Path -Parent $chocoCmd.Path -ErrorAction SilentlyContinue
        $InstallationDirectory = (Resolve-Path ([io.path]::combine($chocoBin,'..'))).Path
    }

    Write-Output (@{
        Ensure = if ($chocoCmd) {'Present'} else {'Absent'}
        InstallationDirectory = $InstallationDirectory
    })
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String]
        $ChocolateyPackageUrl,

        [System.String]
        $PackageFeedUrl,

        [System.String]
        $Version,

        [System.String]
        $ChocoTempDir,

        [System.String]
        $ProxyLocation,

        [System.Management.Automation.PSCredential]
        $ProxyCredential,

        [System.Boolean]
        $IgnoreProxy,

        [System.String]
        $InstallationDirectory
    )
    $Env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')

    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $ChocoParams = @{}

    if ($ensure -eq 'Present') {
        $AllowedParamName = (Get-Command Install-ChocolateySoftware).Parameters.keys
        foreach ($key in ($PSBoundParameters.keys|Where-Object {$_ -in $AllowedParamName})) {
            if ($PSBoundParameters[$Key]) {
                $null = $ChocoParams.add($Key,$PSBoundParameters[$Key])
            }
        }
        Install-ChocolateySoftware @ChocoParams
    }
    else {
        Uninstall-Chocolatey -InstallDir $InstallationDirectory
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String]
        $ChocolateyPackageUrl,

        [System.String]
        $PackageFeedUrl,

        [System.String]
        $Version,

        [System.String]
        $ChocoTempDir,

        [System.String]
        $ProxyLocation,

        [System.Management.Automation.PSCredential]
        $ProxyCredential,

        [System.Boolean]
        $IgnoreProxy,

        [System.String]
        $InstallationDirectory
    )
    $Env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $ChocoParams = @{}
    if ($InstallDir) {$ChocoParams.Add('InstallDir',$InstallDir)}

    $EnsureTestMap = @{'Present'=$true;'Absent'=$false}

    return ($EnsureTestMap[$Ensure] -eq (Test-ChocolateyInstall @ChocoParams))

}

Export-ModuleMember -Function *-TargetResource
