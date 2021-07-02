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

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')

    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $FeatureConfig = Get-ChocolateyFeature -Name $Name

    return @{
        Ensure = @('Absent', 'Present')[[int][bool]$FeatureConfig.enabled]
        Name   = $FeatureConfig.Name
    }
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

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')

    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    switch ($Ensure)
    {
        'Present'
        {
            Enable-ChocolateyFeature -Name $Name
        }
        'Absent'
        {
            Disable-ChocolateyFeature -Name $Name
        }
    }
}

function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCUseVerboseMessageInDSCResource', '')]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )
    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')

    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $EnsureResultMap = @{
        'Present' = $false
        'Absent'  = $true
    }
    return (Test-ChocolateyFeature -Name $Name -Disabled:($EnsureResultMap[$Ensure]))
}

Export-ModuleMember -Function *-TargetResource
