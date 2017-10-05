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
    if ($ChocoInstallScriptUrl) {$ChocoParams.Add('ChocoInstallScriptUrl',$ChocoInstallScriptUrl)}
    if ($InstaInstallationDirectoryllDir) {$ChocoParams.Add('InstallationDirectory',$InstallationDirectory)}

    if ($ensure -eq 'Present') {
        Install-Chocolatey @ChocoParams
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

