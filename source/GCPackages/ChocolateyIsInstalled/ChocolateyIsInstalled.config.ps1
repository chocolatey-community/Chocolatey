Configuration ChocolateyIsInstalled {
    Import-DscResource -ModuleName Chocolatey

    node ChocolateyIsInstalled {
        ChocolateySoftware chocoSoftwareInstalled {
            Ensure = 'Present'
        }

        ChocolateyPackage chocoSoftwareInstalled {
            Ensure = 'Present'
            Name = 'chocolatey'
        #     Version = 'latest'
        }
    }
}
