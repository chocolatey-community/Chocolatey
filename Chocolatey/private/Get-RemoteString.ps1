function Get-RemoteString {
    [CmdletBinding()]
    param (
        [uri]$url
    )
    Write-Debug "Downloading String from $url"
    $downloader = Get-Downloader $url
    return $downloader.DownloadString($url)
}