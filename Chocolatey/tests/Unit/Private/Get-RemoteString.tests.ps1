InModuleScope Chocolatey {
    Describe Get-RemoteString {

        Context 'Default' {
            Mock Get-Downloader -MockWith {
                $Obj = [PSCustomObject]@{}
                $obj | Add-member -MemberType ScriptMethod -Name DownloadString -Value {
                    Param ($url)
                    return @{url=$url;}
                } -PassThru
            }

            It 'Should Return a downloader object' {
                $result = Get-RemoteString -url 'https://my/url'
                $result.url | Should -Be 'https://my/url'
            }
        }
    }
}