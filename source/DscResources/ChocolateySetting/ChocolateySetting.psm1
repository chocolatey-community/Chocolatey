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

    $null = $PSBoundParameters.remove('Ensure')
    $Setting = Get-ChocolateySetting @PSBoundParameters

    $returnValue = @{
        Ensure = $Ensure
        Name   = $Name
        value  = $Setting.Value
    }

    $returnValue
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
        $Name,

        [Parameter()]
        [System.String]
        $value
    )
    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $null = $PSBoundParameters.remove('Ensure')

    switch ($Ensure)
    {
        #'Present' {  }
        'Absent'
        {
            if ( $PSBoundParameters.ContainsKey('Value') )
            {
                $PSBoundParameters.remove('Value')
            }
            $null = $PSBoundParameters.add('Unset', $true)
        }
    }
    Write-Verbose "Setting the Chocolatey Setting $Name."
    Set-ChocolateySetting @PSBoundParameters
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

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $value
    )
    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -Verbose:$False

    $null = $PSBoundParameters.remove('Ensure')

    switch ($Ensure)
    {
        'Present'
        {
            $PSBoundParameters['value'] = $Value
        }
        'Absent'
        {
            $PSBoundParameters['value'] = ''
        }
    }

    return (Test-ChocolateySetting @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
