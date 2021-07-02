function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCUseVerboseMessageInDSCResource', '')]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure,

        [Parameter()]
        [System.String]
        $InstallationDirectory
    )
    <#
        ,[string]
        $InstallationDirectory
    #>
    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')

    if ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)
    {
        $chocoBin = Split-Path -Parent $chocoCmd.Path -ErrorAction SilentlyContinue
        $InstallationDirectory = (Resolve-Path ([io.path]::combine($chocoBin, '..'))).Path
    }

    Write-Output (
        @{
            Ensure                = if ($chocoCmd)
            {
                'Present'
            }
            else
            {
                'Absent'
            }
            InstallationDirectory = $InstallationDirectory
        })
}

function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCUseVerboseMessageInDSCResource', '')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure,

        [Parameter()]
        [System.String]
        $ChocolateyPackageUrl,

        [Parameter()]
        [System.String]
        $PackageFeedUrl,

        [Parameter()]
        [System.String]
        $Version,

        [Parameter()]
        [System.String]
        $ChocoTempDir,

        [Parameter()]
        [System.String]
        $ProxyLocation,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ProxyCredential,

        [Parameter()]
        [System.Boolean]
        $IgnoreProxy,

        [Parameter()]
        [System.String]
        $InstallationDirectory
    )
    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')

    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $ChocoParams = @{}

    if ($ensure -eq 'Present')
    {
        $AllowedParamName = (Get-Command Install-ChocolateySoftware).Parameters.keys
        foreach ($key in ($PSBoundParameters.keys | Where-Object { $_ -in $AllowedParamName }))
        {
            if ($PSBoundParameters[$Key])
            {
                $null = $ChocoParams.add($Key, $PSBoundParameters[$Key])
            }
        }
        Install-ChocolateySoftware @ChocoParams
    }
    else
    {
        Uninstall-Chocolatey -InstallDir $InstallationDirectory
    }
}

function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCUseVerboseMessageInDSCResource', '')]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure,

        [Parameter()]
        [System.String]
        $ChocolateyPackageUrl,

        [Parameter()]
        [System.String]
        $PackageFeedUrl,

        [Parameter()]
        [System.String]
        $Version,

        [Parameter()]
        [System.String]
        $ChocoTempDir,

        [Parameter()]
        [System.String]
        $ProxyLocation,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ProxyCredential,

        [Parameter()]
        [System.Boolean]
        $IgnoreProxy,

        [Parameter()]
        [System.String]
        $InstallationDirectory
    )
    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')

    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $ChocoParams = @{}
    if ($InstallDir)
    {
        $ChocoParams.Add('InstallDir', $InstallDir)
    }

    $EnsureTestMap = @{
        'Present' = $true;
        'Absent' = $false
    }

    return ($EnsureTestMap[$Ensure] -eq (Test-ChocolateyInstall @ChocoParams))

}

Export-ModuleMember -Function *-TargetResource
