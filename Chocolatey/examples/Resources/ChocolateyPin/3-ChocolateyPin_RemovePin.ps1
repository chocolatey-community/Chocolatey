configuration Chocolatey 
{
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateyPin AddPintoPackage {
            Ensure  = 'Absent'
            Name    = 'Putty'
            Version = '0.71'
        }
    }
}
