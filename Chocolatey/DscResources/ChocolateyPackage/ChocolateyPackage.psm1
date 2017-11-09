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
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Version
    )
    
    $Env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False
    $TestParams = @{
        Name = $Name
    }
    if($Version) { $TestParams.Add('Version',$Version) }

    $InstalledPackage = Test-ChocolateyPackageIsInstalled @TestParams
    
    $returnValue = @{
        Ensure = @('Absent','Present')[[int]$InstalledPackage.VersionGreaterOrEqual]
        Name = $Name
        Version = $Version
    }

    $returnValue
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
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Version,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ChocolateyOptions,

        [System.Boolean]
        $UpdateOnly
    )

    Begin {
        $Env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')

        #As per Dave Wyatt's : https://powershell.org/forums/topic/hashtable-as-parameter-for-custom-dsc-resource/
        function Convert-CimInstancesToHashtable([Microsoft.Management.Infrastructure.CimInstance[]] $Pairs)
        {
            Write-Verbose ">> Converting CIM Pairs"
            $hash = @{}
            foreach ($pair in $Pairs)
            {
                $hash[$pair.Key] = $pair.Value
            }
            return $hash
        }
        Write-Verbose "Converting CIMInstance[] to hashtable"
        $ChocoOptions = Convert-CimInstancesToHashtable $ChocolateyOptions
    }

    Process {
        Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False
        
        $TestParams = @{
            Name = $Name
        }
        if($Version) { $TestParams.Add('Version',$Version) }

        $testResult = Test-ChocolateyPackageIsInstalled @TestParams
        $ChocoCommand = switch ($Ensure) {
            'Present' {
                if($testResult.VersionGreaterOrEqual) {
                    Get-Command Update-ChocolateyPackage 
                }
                elseif(!$UpdateOnly) {
                    Get-Command Install-ChocolateyPackage 
                }
                else {
                    Write-Verbose "Nothing to do: UpdateOnly : $UpdateOnly"
                    return
                }
                 
            }
            'Absent'  { Get-Command Uninstall-ChocolateyPackage }
        }
        Write-Verbose "$($ChocoCommand.Name) ``"
        Write-Verbose "`t -Name $Name)"
        Write-Verbose "`t -Confirm `$False)"
        Write-Verbose "`t -NoProgress `$true)"
        $ChocoCommandParams = @{
            Name = $Name
            Confirm = $False
            NoProgress = $true
        }
        if ($Version -and $Version -ne 'latest') { $ChocoCommandParams.Add('Version',$Version) }

        #Allow merge but no overrides
        foreach ($ChocoOptionName in $ChocoOptions.Keys) {
            if (
                !$ChocoCommandParams.ContainsKey($ChocoOptionName) -and
                $ChocoCommand.Parameters.ContainsKey($ChocoOptionName)
            )
            {
                Write-Verbose "`t -$ChocoOptionName $($ChocoOptions[$ChocoOptionName])"
                $ChocoCommandParams.Add($ChocoOptionName,$ChocoOptions[$ChocoOptionName])
            }
        }
        Write-Verbose "Starting the Execution..."
        &$ChocoCommand @ChocoCommandParams -verbose | Write-Verbose
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
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Version,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ChocolateyOptions,

        [System.Boolean]
        $UpdateOnly
    )

    $Env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    Import-Module $PSScriptRoot\..\..\Chocolatey.psd1 -verbose:$False

    $TestParams = @{
        Name = $Name
    }
    #Not decided whether Version should be mandatory or not
    if($Version) { $TestParams.Add('Version',$Version) }
    
    $EnsureResultMap = @{
        'Present'=$true
        'Absent'=$false
    }
    Write-Verbose "Testing whether the Package $Name is Installed"
    return ($EnsureResultMap[$Ensure] -eq (Test-ChocolateyPackageIsInstalled @TestParams).VersionGreaterOrEqual)
}


Export-ModuleMember -Function *-TargetResource

