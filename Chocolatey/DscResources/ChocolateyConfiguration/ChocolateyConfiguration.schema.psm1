Configuration ChocolateyConfiguration {
    Param(
        [bool]
        $ChocolateySoftware = $true,

        $PackageFeedUrl = 'https://chocolatey.org/api/v2',
        
        $Sources = @(),
        
        $Packages = @(),
        
        $Settings = @(),
        
        $Features = @(),
        
        $ChocolateyLicenseXML
    )


    Import-DscResource -ModuleName Chocolatey


    ChocolateySoftware InstallChoco {
        Ensure = @('Absent','Present')[([int]$ChocolateySoftware)]
        PackageFeedUrl = $PackageFeedUrl
    }

    if($Sources) {
        foreach($Source in $Sources) {
            $source_DscSplatParams = @{
                ResourceName = $Source.Name
                ExecutionName = "$($Source.Name)_chocoSrc"
                Properties = $Source
                NoInvoke = $true
            }
            (Get-DscSplattedResource @source_DscSplatParams).Invoke($Source)
        }
    }
}