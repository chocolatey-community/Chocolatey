function Get-RemoteString {
    [CmdletBinding()]
    param (
        [string]$url,

        [uri]
        $ProxyLocation,

        [pscredential]
        $ProxyCredential,

        # To bypass the use of any proxy, please set IgnoreProxy
        [switch]
        $IgnoreProxy
    )
    
    Write-Debug "Downloading string from $url"
    $downloaderParams = @{}
    $KeysForDownloader = $PSBoundParameters.keys | Where-Object { $_ -notin @()}
    foreach ($key in $KeysForDownloader ) { 
        Write-Debug "`tWith $key :: $($PSBoundParameters[$key])"
        $null = $downloaderParams.Add($key,$PSBoundParameters[$key]) 
    }
    $downloader = Get-Downloader @downloaderParams
    return $downloader.DownloadString($url)
}