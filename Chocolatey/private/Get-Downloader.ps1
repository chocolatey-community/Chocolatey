<#
.SYNOPSIS
    Returns a Downloader object (System.Net.WebClient) set up.

.DESCRIPTION
    Returns a Downloader object configured with Proxy and Credential.
    This is used during the Chocolatey software Install Process,
    to retrieve metadata and to download the file.

.PARAMETER url
    Url to execute the request against.

.PARAMETER ProxyLocation
    Url of the Proxy to use for executing request.

.PARAMETER ProxyCredential
    Credential to be used by the proxy. By default it will try to use the cached credential.

.PARAMETER IgnoreProxy
    Bypass the proxy for this request.

.EXAMPLE
    Get-Downloader -Url https://chocolatey.org/api/v2
#>
function Get-Downloader {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory
        )]
        [string]
        $url,

        [uri]
        $ProxyLocation,

        [pscredential]
        $ProxyCredential,

        # To bypass the use of any proxy, please set IgnoreProxy
        [switch]
        $IgnoreProxy
    )

    $downloader = new-object System.Net.WebClient
    $defaultCreds = [System.Net.CredentialCache]::DefaultCredentials

    if ($defaultCreds -ne $null) {
        $downloader.Credentials = $defaultCreds
    }

    if ($ignoreProxy -ne $null -and $ignoreProxy -eq 'true') {
        Write-Debug "Explicitly bypassing proxy"
        $downloader.Proxy = [System.Net.GlobalProxySelection]::GetEmptyWebProxy()
    }
    else {  # check if a proxy is required
        if ($ProxyLocation -and ![string]::IsNullOrEmpty($ProxyLocation)) {
            $proxy = New-Object System.Net.WebProxy($ProxyLocation, $true)
            if ($null -ne $ProxyCredential) {
                $proxy.Credentials = $ProxyCredential
            }

            Write-Debug "Using explicit proxy server '$ProxyLocation'."
            $downloader.Proxy = $proxy
        }
        elseif (!$downloader.Proxy.IsBypassed($url)) {
            # system proxy (pass through)
            $creds = $defaultCreds
            if ($creds -eq $null) {
                Write-Debug "Default credentials were null. Attempting backup method"
                Throw "Could not download required file from $url"
            }

            $proxyaddress = $downloader.Proxy.GetProxy($url).Authority
            Write-Debug "Using system proxy server '$proxyaddress'."
            $proxy = New-Object System.Net.WebProxy($proxyaddress)
            $proxy.Credentials = $creds
            $downloader.Proxy = $proxy
        }
    }

  return $downloader
}
