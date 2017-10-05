configuration Default {
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateySoftware nugetproviderRemove {
            Ensure = 'Present'
        }
    }
}

configuration Remove {
    Import-DscResource -ModuleName Chocolatey

    Node localhost {
        ChocolateySoftware nugetproviderRemove {
            Ensure = 'Absent'
        }
    }
}