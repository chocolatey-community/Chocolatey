function Get-ChocolateyFeature {
    [CmdletBinding()]
    Param(
        [Parameter(
            ValueFromPipeline
            ,ValueFromPipelineByPropertyName
        )]
        [Alias('Name')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Feature = '*'
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

        foreach ($Name in $Feature) {
            if ($Name -ne '*') {
                Write-Verbose ('Searching for Feature named ${0}' -f [Security.SecurityElement]::Escape($Name))
                $FeatureNodes = $ChocoXml.SelectNodes("//feature[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='$([Security.SecurityElement]::Escape($Name.ToLower()))']")
            }
            else {
                Write-Verbose 'Returning all Sources configured'
                $FeatureNodes = $ChocoXml.chocolatey.features.childNodes
            }

            foreach ($FeatureNode in $FeatureNodes) {
                $FeatureObject = [PSCustomObject]@{
                    PSTypeName  = 'Chocolatey.Feature'
                }
                foreach ($property in $FeatureNode.Attributes.name) {
                    $FeaturePropertyParam = @{
                        MemberType = 'NoteProperty'
                        Name = $property
                        Value = $FeatureNode.($property).ToString()
                    }
                    $FeatureObject | Add-Member @FeaturePropertyParam
                }
                Write-Output $FeatureObject
            }
        }
    }
}