<#
.SYNOPSIS
    Download a file from url using specified proxy settings.

.DESCRIPTION
    Helper function to Download a file from a given url
    using specified proxy settings.

.PARAMETER url
    URL of the file to download

.PARAMETER file
    File path and name to save the downloaded file to.

.PARAMETER ProxyLocation
    Proxy uri to use for the download.

.PARAMETER ProxyCredential
    Credential to use for authenticating to the proxy.
    By default it will try to load cached credentials.

.PARAMETER IgnoreProxy
    Bypass the proxy for this request.

.EXAMPLE
    Get-RemoteFile -Url https://chocolatey.org/api/v2/0.10.8/ -file C:\chocolatey.zip

#>
function Get-RemoteFile
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $url,

        [Parameter()]
        [System.String]
        $file,

        [Parameter()]
        [uri]
        $ProxyLocation,

        [Parameter()]
        [pscredential]
        $ProxyCredential,

        [Parameter()]
        # To bypass the use of any proxy, please set IgnoreProxy
        [switch]
        $IgnoreProxy
    )

    Write-Debug "Downloading $url to $file"
    $downloaderParams = @{}
    $KeysForDownloader = $PSBoundParameters.keys | Where-Object { $_ -notin @('file') }
    foreach ($key in $KeysForDownloader )
    {
        Write-Debug "`tWith $key :: $($PSBoundParameters[$key])"
        $null = $downloaderParams.Add($key , $PSBoundParameters[$key])
    }
    $downloader = Get-Downloader @downloaderParams
    $downloader.DownloadFile($url, $file)
}
