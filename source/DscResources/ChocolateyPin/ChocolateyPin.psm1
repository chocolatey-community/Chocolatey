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
        $Name,

        [Parameter()]
        [System.String]
        $Version
    )

    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False
    $null = $PSBoundParameters.remove('Ensure')

    $returnValue = @{
        Ensure  = $Ensure
        Name    = $Name
        Version = $Version
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
        $Version
    )

    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False
    $null = $PSBoundParameters.remove('Ensure')

    switch ($Ensure)
    {
        'Absent'
        {
            if ( $PSBoundParameters.ContainsKey('Version') )
            {
                $PSBoundParameters.remove('Version')
            }
            Write-Verbose "Remove Pin for the Chocolatey Package $Name."
            Remove-ChocolateyPin @PSBoundParameters
        }
        'Present'
        {
            Write-Verbose "Add Pin to the Chocolatey Package $Name."
            Add-ChocolateyPin @PSBoundParameters
        }
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

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Version
    )

    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False
    $null = $PSBoundParameters.remove('Ensure')

    switch ($Ensure)
    {
        'Present'
        {
            $PSBoundParameters['Version'] = $Version
        }
        'Absent'
        {
            $PSBoundParameters['Version'] = ''
        }
    }
    return (Test-ChocolateyPin @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
