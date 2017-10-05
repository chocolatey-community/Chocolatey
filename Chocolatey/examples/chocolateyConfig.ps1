configuration Chocolatey {
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateySoftware ChocoInst {
            Ensure = 'Present'
        }

        ChocolateySource ShouldNotBeThereAnyway {
            DependsOn = '[ChocolateyPackage]Putty'
            Ensure = 'Absent'
            Name = 'ShouldNotBeThereAnyway'
        }

        ChocolateySource chocolatey {
            DependsOn = '[ChocolateyPackage]Putty'
            Ensure = 'Present'
            Name = 'chocolatey'
            Source = 'https://chocolatey.org/api/v2/'
            disabled = $true
            priority = 5
        }

        ChocolateySource MyOtherChocolatey {
            DependsOn = '[ChocolateyPackage]Putty'
            Ensure = 'Present'
            Name = 'MyOtherChocolatey'
            Source = 'http://This/is/another/feed/'
            SelfService = $true
            #bypass default to $false
            disabled = $True
            priority = 10
            #No Creds on this one anyway
        }

        ChocolateyFeature NoVIrusCheck {
            Ensure = 'Absent'
            Name = 'viruscheck'
        }

        ChocolateyPackage Putty {
           DependsOn = '[ChocolateyInstall]ChocoInst'
            Ensure  = 'Present'
            Name    = 'Putty'
            Version = 'Latest'
            ChocolateyOptions = @{ source = 'https://chocolatey.org/api/v2/'}
        }

        
    }
}