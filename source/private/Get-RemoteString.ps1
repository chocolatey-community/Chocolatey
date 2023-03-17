<#
.SYNOPSIS
    Download the content from url using specified proxy settings.

.DESCRIPTION
    Helper function to Download the content from a url
    using specified proxy settings.

.PARAMETER url
    URL of the file to download.

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
    Get-RemoteString -Url https://chocolatey.org/install.ps1
#>
function Get-RemoteString
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $url,

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

    Write-Debug "Downloading string from $url"
    $downloaderParams = @{}
    $KeysForDownloader = $PSBoundParameters.keys | Where-Object { $_ -notin @() }
    foreach ($key in $KeysForDownloader )
    {
        Write-Debug -Message "`tWith $key :: $($PSBoundParameters[$key])"
        $null = $downloaderParams.Add($key, $PSBoundParameters[$key])
    }

    $downloader = Get-Downloader @downloaderParams
    return $downloader.DownloadString($url)
}
