configuration Chocolatey 
{
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateyPackage Putty {
            Ensure  = 'Present'
            Name    = 'Putty'
            Version = 'Latest'
            ChocolateyOptions = @{ source = 'https://chocolatey.org/api/v2/' }
        }
    }
}