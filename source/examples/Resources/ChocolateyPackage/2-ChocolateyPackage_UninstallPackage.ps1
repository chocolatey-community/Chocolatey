configuration Chocolatey 
{
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateyPackage Putty {
            Ensure  = 'Absent'
            Name    = 'Putty'
        }
    }
}