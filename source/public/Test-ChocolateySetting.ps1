
<#
.SYNOPSIS
    Test Whether a setting is set, enabled or not found

.DESCRIPTION
    Some settings might not be available in your version or SKU.
    This command allows you to test the values of a named setting.

.PARAMETER Name
    Name of the Setting to verify

.PARAMETER Value
    Test if the Setting value provided matches with the one set on the config file.

.PARAMETER Unset
    Test if the Setting is disabled, the default is to test if the feature is enabled.

.EXAMPLE
    Test-ChocolateySetting -Name SettingName -value ''

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsConfig
#>
function Test-ChocolateySetting
{
    [CmdletBinding(
        DefaultParameterSetName = 'Set'
    )]
    [OutputType([Bool])]
    param (
        [Parameter(
            Mandatory = $true
            , ValueFromPipelineByPropertyName
        )]
        [Alias('Setting')]
        [System.String]
        $Name,

        [Parameter(
            Mandatory = $true
            , ValueFromPipelineByPropertyName
            , ParameterSetName = 'Set'
        )]
        [AllowEmptyString()]
        [AllowNull()]
        [System.String]
        $Value,

        [Parameter(
            ValueFromPipelineByPropertyName
            , ParameterSetName = 'Unset'
        )]
        [switch]
        $Unset
    )

    process
    {
        if (-not (Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue))
        {
            throw "Chocolatey Software not found."
        }

        if (!($Setting = Get-ChocolateySetting -Name $Name))
        {
            Write-Warning "Chocolatey Setting $Name cannot be found."
            return $false
        }
        $Setting | Write-Verbose
        if ($Unset)
        {
            $Value = ''
        }

        $Value = $ExecutionContext.InvokeCommand.ExpandString($Value).TrimEnd(@('/', '\'))
        if ([string]$Setting.value -eq $Value)
        {
            Write-Verbose ("The Chocolatey Setting {0} is set to '{1}' as expected." -f $Name, $Value)
            return $true
        }
        else
        {
            Write-Verbose ("The Chocolatey Setting {0} is NOT set to '{1}' as expected:{2}" -f $Name, $Setting.value, $Value)
            return $False
        }
    }
}
