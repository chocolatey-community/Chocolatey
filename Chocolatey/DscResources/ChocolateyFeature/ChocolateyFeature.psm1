function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    <#

    #>

    $Env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $FeatureConfig = Get-ChocolateyFeature -Name $Name

    return @{
        Ensure = @('Absent','Present')[[int][bool]$FeatureConfig.enabled]
        Name = $FeatureConfig.Name
    }
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

        [parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    $Env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    Switch ($Ensure) {
        'Present' { Enable-ChocolateyFeature -name $Name}
        'Absent'  { Disable-ChocolateyFeature -name $Name}
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

        [parameter(Mandatory = $true)]
        [System.String]
        $Name
    )
    $Env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $EnsureResultMap = @{
        'Present'=$false
        'Absent'=$true
    }
    
    return (Test-ChocolateyFeature -Name $Name -Disabled:($EnsureResultMap[$Ensure]))
}


Export-ModuleMember -Function *-TargetResource

