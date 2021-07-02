<#
.SYNOPSIS
    List the source from Configuration file.

.DESCRIPTION
    Allows you to list the configured source from the Chocolatey Configuration file.
    When it comes to the source location, this can be a folder/file share
    or an http location. If it is a url, it will be a location you can go
    to in a browser and it returns OData with something that says Packages
    in the browser, similar to what you see when you go
    to https://chocolatey.org/api/v2/.

.PARAMETER Name
    Retrieve specific source details from configuration file.

.EXAMPLE
    Get-ChocolateySource -Name Chocolatey

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsSource
#>
function Get-ChocolateySource
{
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipeline
            , ValueFromPipelineByPropertyName
        )]
        [Alias('id')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name = '*'
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

        foreach ($id in $Name)
        {
            if ($id -ne '*')
            {
                Write-Verbose ('Searching for Source with id ${0}' -f [Security.SecurityElement]::Escape($id))
                $sourceNodes = $ChocoXml.SelectNodes("//source[translate(@id,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='$([Security.SecurityElement]::Escape($id.ToLower()))']")
            }
            else
            {
                Write-Verbose 'Returning all Sources configured.'
                $sourceNodes = $ChocoXml.chocolatey.sources.childNodes
            }

            foreach ($source in $sourceNodes)
            {
                Write-Output (
                    [PSCustomObject]@{
                        PSTypeName  = 'Chocolatey.Source'
                        Name        = $source.id
                        Source      = $source.value
                        disabled    = [bool]::Parse($source.disabled)
                        bypassProxy = [bool]::Parse($source.bypassProxy)
                        selfService = [bool]::Parse($source.selfService)
                        priority    = [int]$source.priority
                        username    = $source.user
                        password    = $source.password
                    })
            }
        }
    }
}
