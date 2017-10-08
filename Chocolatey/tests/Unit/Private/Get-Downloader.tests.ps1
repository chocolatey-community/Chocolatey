InModuleScope Chocolatey {
    Describe Get-Downloader {

        Context 'Default' {
            $Result = Get-Downloader -url https://chocolatey.org/api/v2
            It 'Should Return a downloader object' {
                $result | Should not BeNullOrEmpty
            }
            It 'Should be of type System.Net.WebClient' {
                $result | should beOfType [System.Net.WebClient]
            }
        }
    }
}