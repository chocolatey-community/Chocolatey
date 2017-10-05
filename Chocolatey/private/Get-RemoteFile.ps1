function Get-RemoteFile {
    [CmdletBinding()]
    param (
        [string]$url,

        [string]$file,

        [uri]
        $ProxyLocation,

        [pscredential]
        $ProxyCredential,

        # To bypass the use of any proxy, please set IgnoreProxy
        [switch]
        $IgnoreProxy
    )
    
    Write-Debug "Downloading $url to $file"
    $downloaderParams = @{}
    $KeysForDownloader = $PSBoundParameters.keys | Where-Object { $_ -notin @('file')}
    foreach ($key in $KeysForDownloader ) { 
        Write-Debug "`tWith $key :: $($PSBoundParameters[$key])"
        $null = $downloaderParams.Add($key ,$PSBoundParameters[$key]) 
    }
    $downloader = Get-Downloader @downloaderParams
    $downloader.DownloadFile($url, $file)
}