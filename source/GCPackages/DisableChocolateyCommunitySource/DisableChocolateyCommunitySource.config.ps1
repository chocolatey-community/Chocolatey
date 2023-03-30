Configuration DisableChocolateyCommunitySource {
    Import-DscResource -ModuleName Chocolatey

    node DisableChocolateyCommunitySource {
        ChocolateySource disableChocoSource {
            Ensure = 'Present'
            Name = 'chocolatey'
            Disabled = $true
        }
    }
}
