
<#
.SYNOPSIS
    Gets the Settings set in the Configuration file.

.DESCRIPTION
    This command looks up in the Chocolatey Config file, and returns
    the Settings available from there.

.PARAMETER Setting
    Name of the Setting when retrieving a single one or a specific list.
    It defaults to returning all Settings available in the config file.

.EXAMPLE
    Get-ChocolateySetting -Name CacheLocation

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsConfig
#>
function Get-ChocolateySetting
{
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipeline
            , ValueFromPipelineByPropertyName
        )]
        [Alias('Name')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Setting = '*'
    )
    begin
    {
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue))
        {
            throw "Chocolatey Software not found."
        }

        $ChocoConfigPath = join-path $chocoCmd.Path ..\..\config\chocolatey.config -Resolve
        $ChocoXml = [xml]::new()
        $ChocoXml.Load($ChocoConfigPath)
    }

    process
    {
        if (!$ChocoXml)
        {
            throw "Error with Chocolatey config."
        }

        foreach ($Name in $Setting)
        {
            if ($Name -ne '*')
            {
                Write-Verbose ("Searching for Setting named {0}" -f [Security.SecurityElement]::Escape($Name))
                $SettingNodes = $ChocoXml.SelectNodes("//add[translate(@key,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='$([Security.SecurityElement]::Escape($Name.ToLower()))']")
            }
            else
            {
                Write-Verbose 'Returning all Sources configured.'
                $SettingNodes = $ChocoXml.chocolatey.config.childNodes
            }

            foreach ($SettingNode in $SettingNodes)
            {
                $SettingObject = [PSCustomObject]@{
                    PSTypeName = 'Chocolatey.Setting'
                }
                foreach ($property in $SettingNode.Attributes.name)
                {
                    $SettingPropertyParam = @{
                        MemberType = 'NoteProperty'
                        Name       = $property
                        Value      = $SettingNode.($property).ToString()
                    }
                    $SettingObject | Add-Member @SettingPropertyParam
                }
                Write-Output $SettingObject
            }
        }
    }
}
