InModuleScope Chocolatey {
    Describe Get-Downloader {

        Context 'Default' {
            It 'Should be true' {
                $true | Should be $true
            }
        }
    }
}