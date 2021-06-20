configuration Chocolatey 
{
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateySource ChocolateyOrg {
            Ensure   = 'Present'
            Name     = 'Chocolatey'
            Source   = 'https://chocolatey.org/api/v2'
            Priority = 0
            Disabled = $false
        }
    }
}
