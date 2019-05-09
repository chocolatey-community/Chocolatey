configuration Chocolatey 
{
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateySetting ChococacheLocation {
            Ensure = 'Present'
            Name   = 'cacheLocation'
            Value  = 'C:\Temp\Choco'
        }
    }
}
