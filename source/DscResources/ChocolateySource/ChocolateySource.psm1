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
<#
        [Parameter()]
        [System.String]
        $Source,

        [Parameter()]
        [System.Boolean]
        $Disabled,

        [Parameter()]
        [System.Boolean]
        $ByPassProxy,

        [Parameter()]
        [System.Boolean]
        $SelfService,

        [Parameter()]
        [System.Int]
        $priority,

        [Parameter()]
        [System.String]
        $username
        #>
    )
    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')

    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $ChocoSourceParams = @{
        Name = $Name
    }
    switch ($PSBoundParameters.keys)
    {
        'Source'
        {
            $ChocoSourceParams.add('Source', $Source)
        }
        'disabled'
        {
            $ChocoSourceParams.Add('disabled', $Disabled)
        }
        'bypassproxy'
        {
            $ChocoSourceParams.add('bypassproxy', $bypassproxy)
        }
        'selfservice'
        {
            $ChocoSourceParams.add('selfservice', $selfservice)
        }
        'priority'
        {
            $ChocoSourceParams.add('priority', $priority)
        }
    }

    if (!($SourceConfigured = Get-ChocolateySource @ChocoSourceParams) )
    {
        Write-verbose ("Source $Name not found with configuration `r`n{0}" -f ($ChocoSourceParams | Format-list))
    }
    else
    {
        Write-Verbose "Source $Name has an exact match."
    }

    return @{
        Source      = $SourceConfigured.Source
        disabled    = $SourceConfigured.disabled
        bypassproxy = $sourceconfigured.bypassproxy
        selfservice = $SourceConfigured.selfservice
        priority    = $SourceConfigured.priority
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
        $Name,

        [Parameter()]
        [System.String]
        $Source,

        [Parameter()]
        [System.Int16]
        $Priority,

        [Parameter()]
        [System.Boolean]
        $Disabled,

        [Parameter()]
        [System.Boolean]
        $BypassProxy,

        [Parameter()]
        [System.Boolean]
        $SelfService,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')

    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $ChocoSourceParams = @{
        Name = $Name
    }
    switch ($PSBoundParameters.keys)
    {
        'Source'
        {
            $ChocoSourceParams.add('Source', $Source)
        }
        'disabled'
        {
            $ChocoSourceParams.Add('disabled', $Disabled)
        }
        'bypassproxy'
        {
            $ChocoSourceParams.add('bypassproxy', $bypassproxy)
        }
        'selfservice'
        {
            $ChocoSourceParams.add('selfservice', $selfservice)
        }
        'priority'
        {
            $ChocoSourceParams.add('priority', $priority)
        }
        'Credential'
        {
            $ChocoSourceParams.add('Credential', $Credential)
        }
    }

    switch ($Ensure)
    {
        'Present'
        {
            #If we only ensure a Source is Enabled/Disabled by Name, without other arguments
            if (!$ChocoSourceParams.keys.Where{ $_ -notin @('Name', 'Disabled') } )
            {
                if ($Disabled)
                {
                    Disable-ChocolateySource -Name $Name -NoProgress
                }
                else
                {
                    Enable-ChocolateySource -Name $Name -NoProgress
                }
            }
            else
            {
                #If we provide more information, we're given an expected state
                Register-ChocolateySource @ChocoSourceParams -noProgress
            }
        }
        'Absent'
        {
            Unregister-ChocolateySource @ChocoSourceParams -noProgress
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
        $Source,

        [Parameter()]
        [System.Int16]
        $Priority,

        [Parameter()]
        [System.Boolean]
        $Disabled,

        [Parameter()]
        [System.Boolean]
        $BypassProxy,

        [Parameter()]
        [System.Boolean]
        $SelfService,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    $Env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $ChocoSourceParams = @{
        Name = $Name
    }
    switch ($PSBoundParameters.keys)
    {
        'Source'
        {
            $ChocoSourceParams.add('Source', $Source)
        }
        'disabled'
        {
            $ChocoSourceParams.Add('disabled', $Disabled)
        }
        'bypassproxy'
        {
            $ChocoSourceParams.add('bypassproxy', $bypassproxy)
        }
        'selfservice'
        {
            $ChocoSourceParams.add('selfservice', $selfservice)
        }
        'priority'
        {
            $ChocoSourceParams.add('priority', $priority)
        }
        'Credential'
        {
            $ChocoSourceParams.add('Credential', $Credential)
        }
    }

    $EnsureResultMap = @{
        'Present' = $true
        'Absent'  = $false
    }

    #Test-Chocolatey source return false when source name does not exist
    # the differences of compare-object when not an exact match with properties

    if (($SourceDifferences = Test-ChocolateySource @ChocoSourceParams) -or $SourceDifferences -eq $false)
    {
        if ( ($SourceDifferences -eq $False) -and
            $Disabled -and
            $Ensure -eq 'Present' -and
            !($ChocoSourceParams.Keys.where{ $_ -notin @('Name', 'Disabled') } )
        )
        {
            # 1. The Source does not exist
            # 2. We want to ensure that
            # 3.    it's only disabled
            # 4. we don't provide more data to register a source as disabled
            #  so it does not need disabling (edge case)
            $SourceDoesMatch = $True
        }
        else
        {
            $SourceDoesMatch = $false
        }

        # If the source does not match, it's a good thing when Ensure = 'Absent'
        Write-Verbose "Differences = `r`n$($SourceDifferences | Out-String)"
    }
    else
    {
        Write-Verbose "The sources match exactly with the provided parameters."
        $SourceDoesMatch = $true
    }

    return ($EnsureResultMap[$Ensure] -eq $SourceDoesMatch )
}

Export-ModuleMember -Function *-TargetResource
