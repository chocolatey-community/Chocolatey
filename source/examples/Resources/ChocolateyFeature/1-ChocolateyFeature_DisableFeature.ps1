configuration Chocolatey {
    
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateyFeature NoVIrusCheck {
            Ensure = 'Absent'
            Name   = 'viruscheck'
        }
    }
}
