configuration Chocolatey 
{
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateySource ChocolateyOrg {
            Ensure = 'Absent'
            Name   = 'Chocolatey'
        }
    }
}