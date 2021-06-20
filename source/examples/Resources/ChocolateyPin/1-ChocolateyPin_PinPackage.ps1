configuration Chocolatey 
{
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateyPin AddPintoPackage {
            Ensure = 'Present'
            Name   = 'Putty'
        }
    }
}
