configuration Chocolatey {
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateySoftware ChocoInst {
            Ensure = 'Present'
        }

        ChocolateySource ChocolateyOrg {
            DependsOn = '[ChocolateySoftware]ChocoInst'
            Ensure = 'Present'
            Name = 'Chocolatey'
            Source = 'https://chocolatey.org/api/v2'
            Priority = 0
            Disabled = $false
        }

        ChocolateyFeature NoVIrusCheck {
            Ensure = 'Absent'
            Name = 'viruscheck'
        }

        ChocolateyPackage Putty {
           DependsOn = '[ChocolateySoftware]ChocoInst'
            Ensure  = 'Present'
            Name    = 'Putty'
            Version = 'Latest'
            ChocolateyOptions = @{ source = 'https://chocolatey.org/api/v2/' }
        }
    }
}