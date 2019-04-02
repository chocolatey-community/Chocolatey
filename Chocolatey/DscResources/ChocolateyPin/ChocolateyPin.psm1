function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Version
    )

    $Env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $null = $PSBoundParameters.remove('Ensure')

    $returnValue = @{
        Ensure = $Ensure
        Name = $Name
        Version = $Version
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Version
    )
    $Env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $null = $PSBoundParameters.remove('Ensure')

    switch ($Ensure) {
        #'Present' {  }
        'Absent'  {
            if ( $PSBoundParameters.ContainsKey('Value') ) {
                $PSBoundParameters.remove('Value')
            }

            $null = $PSBoundParameters.add('Unset',$true) 
        }
    }

    Write-Verbose "Setting the Chocolatey Package $Name."
    Set-ChocolateySetting @PSBoundParameters
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
        $Name,

        [System.String]
        $Version
    )
    $Env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $null = $PSBoundParameters.remove('Ensure')
    
    switch ($Ensure) {
        'Present' { $PSBoundParameters['value'] = $Value }
        'Absent'  { $PSBoundParameters['value'] = '' }
    }

    return (Test-ChocolateySetting @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
