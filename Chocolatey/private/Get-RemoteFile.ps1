function Get-RemoteFile {
    [CmdletBinding()]
    param (
        [string]$url,
        [string]$file
    )
    
    Write-Debug "Downloading $url to $file"
    $downloader = Get-Downloader $url
    $downloader.DownloadFile($url, $file)
}