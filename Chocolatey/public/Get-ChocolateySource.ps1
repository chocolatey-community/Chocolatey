function Get-ChocolateySource {
    [CmdletBinding()]
    Param(
        [Parameter(
            ValueFromPipeline
            ,ValueFromPipelineByPropertyName
        )]
        [Alias('id')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name = '*'
    )
    Begin {
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found"
        }
        $ChocoConfigPath = join-path $chocoCmd.Path ..\..\config\chocolatey.config -Resolve
        $ChocoXml = [xml]::new()
        $ChocoXml.Load($ChocoConfigPath)
    }

    Process {
        if (!$ChocoXml) {
            Throw "Error with Chocolatey config"
        }

        foreach ($id in $Name) {
            if ($id -ne '*') {
                Write-Verbose ('Searching for Source with id ${0}' -f [Security.SecurityElement]::Escape($id))
                $sourceNodes = $ChocoXml.SelectNodes("//source[translate(@id,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='$([Security.SecurityElement]::Escape($id.ToLower()))']")
            }
            else {
                Write-Verbose 'Returning all Sources configured'
                $sourceNodes = $ChocoXml.chocolatey.sources.childNodes
            }

            foreach ($source in $sourceNodes) {
                Write-Output ([PSCustomObject]@{
                    PSTypeName  = 'Chocolatey.Source'
                    Name          = $source.id
                    Source       = $source.value
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