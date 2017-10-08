InModuleScope Chocolatey {
    Describe Get-RemoteFile {

        Context 'Default' {
            Mock Get-Downloader -MockWith {
                $Obj = [PSCustomObject]@{}
                $obj | Add-member -MemberType ScriptMethod -Name DownloadFile -Value {
                    Param ($url,$file)
                    return @{url=$url;file=$file}
                } -PassThru
            }

            It 'Should Return a downloader object' {
                $result = Get-RemoteFile -url 'https://my/url' -File 'C:\test.zip'
                $result.url | Should be 'https://my/url'
                $result.file | Should be 'C:\test.zip'
            }
        }
    }
}