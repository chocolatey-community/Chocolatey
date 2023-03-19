# =====================================================================
# Copyright 2017 Chocolatey Software, Inc, and the
# original authors/contributors from ChocolateyGallery
# Copyright 2011 - 2017 RealDimensions Software, LLC, and the
# original authors/contributors from ChocolateyGallery
# at https://github.com/chocolatey/chocolatey.org
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# =====================================================================

<#
.SYNOPSIS
    Install the Chocolatey Software from a URL to download the binary from.

.DESCRIPTION
    Install Chocolatey Software either from a fixed URL where the chocolatey nupkg is stored,
    or from the url of a NuGet feed containing the Chocolatey Package.
    A version can be specified to lookup the Package feed for a specific version, and install it.
    A proxy URL and credential can be specified to fetch the Chocolatey package, or the proxy configuration
    can be ignored.

.PARAMETER ChocolateyPackageUrl
    Exact URL of the chocolatey package. This can be an HTTP server, a network or local path.
    This must be the .nupkg package as downloadable from here: https://chocolatey.org/packages/chocolatey

.PARAMETER PackageFeedUrl
    Url of the NuGet Feed API to use for looking up the latest version of Chocolatey (available on that feed).
    This is also used when searching for a specific version, doing a lookup via an Odata filter.

.PARAMETER Version
    Version to install if you want to be specific, this is the way to Install a pre-release version, as when not specified,
    the latest non-prerelease version is looked up from the feed defined in PackageFeedUrl.

.PARAMETER ChocoTempDir
    The temporary folder to extract the Chocolatey Binaries during install. This does not set the Chocolatey Cache dir.

.PARAMETER ProxyLocation
    Proxy url to use when downloading the Chocolatey Package for installation.

.PARAMETER ProxyCredential
    Credential to authenticate to the proxy, if not specified but the ProxyLocation is set, an attempt
    to use the Cached credential will be made.

.PARAMETER IgnoreProxy
    Ensure the proxy is bypassed when downloading the Chocolatey Package from the URL.

.PARAMETER InstallationDirectory
    Set the Installation Directory for Chocolatey, by creating the Environment Variable. This will persist after the installation.

.EXAMPLE
    Install latest chocolatey software from the Community repository (non pre-release version)
    Install-ChocolateySoftware

.EXAMPLE
    # Install latest chocolatey software from a custom internal feed
    Install-ChocolateySoftware -PackageFeedUrl https://proget.mycorp.local/nuget/Choco

.NOTES
    Please raise issues at https://github.com/gaelcolas/Chocolatey/issues
#>
function Install-ChocolateySoftware
{
    [CmdletBinding(
        DefaultParameterSetName = 'FromFeedUrl'
    )]
    param (
        [Parameter(
            ParameterSetName = 'FromPackageUrl'
        )]
        [uri]
        $ChocolateyPackageUrl,

        [Parameter(
            ParameterSetName = 'FromFeedUrl'
        )]
        [uri]
        $PackageFeedUrl = 'https://chocolatey.org/api/v2',

        [Parameter()]
        [System.String]
        $Version,

        [Parameter()]
        [System.String]
        $ChocoTempDir,

        [Parameter()]
        [uri]
        $ProxyLocation,

        [Parameter()]
        [pscredential]
        $ProxyCredential,

        [Parameter()]
        [switch]
        $IgnoreProxy,

        [Parameter()]
        [System.String]
        $InstallationDirectory
    )

    if ($PSVersionTable.PSVersion.Major -lt 4)
    {
        Repair-PowerShellOutputRedirectionBug
    }

    # Attempt to set highest encryption available for SecurityProtocol.
    # PowerShell will not set this by default (until maybe .NET 4.6.x). This
    # will typically produce a message for PowerShell v2 (just an info
    # message though)
    try
    {
        # Set TLS 1.2 (3072), then TLS 1.1 (768), then TLS 1.0 (192), finally SSL 3.0 (48)
        # Use integers because the enumeration values for TLS 1.2 and TLS 1.1 won't
        # exist in .NET 4.0, even though they are addressable if .NET 4.5+ is
        # installed (.NET 4.5 is an in-place upgrade).
        [System.Net.ServicePointManager]::SecurityProtocol = 3072 -bor 768 -bor 192
    }
    catch
    {
        Write-Warning 'Unable to set PowerShell to use TLS 1.2 and TLS 1.1 due to old .NET Framework installed. If you see underlying connection closed or trust errors, you may need to do one or more of the following: (1) upgrade to .NET Framework 4.5+ and PowerShell v3, (2) specify internal Chocolatey package location (set $env:chocolateyDownloadUrl prior to install or host the package internally), (3) use the Download + PowerShell method of install. See https://chocolatey.org/install for all install options.'
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        'FromFeedUrl'
        {
            if ($PackageFeedUrl -and ![string]::IsNullOrEmpty($Version))
            {
                Write-Verbose "Downloading specific version of Chocolatey: $Version"
                $url = "$PackageFeedUrl/package/chocolatey/$Version"
            }
            else
            {
                if (![string]::IsNullOrEmpty($PackageFeedUrl))
                {
                    $url = $PackageFeedUrl
                }
                else
                {
                    $url = 'https://chocolatey.org/api/v2'
                }
                Write-Verbose "Getting latest version of the Chocolatey package for download."
                $url = "$url/Packages()?`$filter=((Id%20eq%20%27chocolatey%27)%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion"
                Write-Debug "Retrieving Binary URL from Package Metadata: $url"

                $GetRemoteStringParams = @{
                    url = $url
                }
                $GetRemoteStringParamsName = (get-command Get-RemoteString).parameters.keys
                $KeysForRemoteString = $PSBoundParameters.keys | Where-Object { $_ -in $GetRemoteStringParamsName }
                foreach ($key in $KeysForRemoteString )
                {
                    Write-Debug "`tWith $key :: $($PSBoundParameters[$key])"
                    $null = $GetRemoteStringParams.Add($key , $PSBoundParameters[$key])
                }
                [xml]$result = Get-RemoteString @GetRemoteStringParams
                Write-Debug "New URL for nupkg: $url"
                $url = $result.feed.entry.content.src
            }
        }
        'FromPackageUrl'
        {
            #ignores version
            Write-Verbose "Downloading Chocolatey from : $ChocolateyPackageUrl"
            $url = $ChocolateyPackageUrl
        }
    }

    if ($null -eq $env:TEMP)
    {
        $env:TEMP = Join-Path $Env:SYSTEMDRIVE 'temp'
    }

    $tempDir = [io.path]::Combine($Env:TEMP, 'chocolatey', 'chocInstall')
    if (![System.IO.Directory]::Exists($tempDir))
    {
        $null = New-Item -path $tempDir -ItemType Directory
    }
    $file = Join-Path $tempDir "chocolatey.zip"

    # Download the Chocolatey package
    Write-Verbose "Getting Chocolatey from $url."
    $GetRemoteFileParams = @{
        url  = $url
        file = $file
    }
    $GetRemoteFileParamsName = (get-command Get-RemoteFile).parameters.keys
    $KeysForRemoteFile = $PSBoundParameters.keys | Where-Object { $_ -in $GetRemoteFileParamsName }
    foreach ($key in $KeysForRemoteFile )
    {
        Write-Debug "`tWith $key :: $($PSBoundParameters[$key])"
        $null = $GetRemoteFileParams.Add($key , $PSBoundParameters[$key])
    }
    $null = Get-RemoteFile @GetRemoteFileParams

    # unzip the package
    Write-Verbose "Extracting $file to $tempDir..."

    if ($PSVersionTable.PSVersion.Major -ge 5)
    {
        Expand-Archive -Path "$file" -DestinationPath "$tempDir" -Force
    }
    else
    {
        try
        {
            $shellApplication = new-object -com shell.application
            $zipPackage = $shellApplication.NameSpace($file)
            $destinationFolder = $shellApplication.NameSpace($tempDir)
            $destinationFolder.CopyHere($zipPackage.Items(), 0x10)
        }
        catch
        {
            throw "Unable to unzip package using built-in compression. Error: `n $_"
        }
    }

    # Call chocolatey install
    Write-Verbose "Installing chocolatey on this machine."
    $TempTools = [io.path]::combine($tempDir, 'tools')
    #   To be able to mock
    $chocInstallPS1 = Join-Path $TempTools 'chocolateyInstall.ps1'

    if ($InstallationDirectory)
    {
        [Environment]::SetEnvironmentVariable('ChocolateyInstall', $InstallationDirectory, 'Machine')
        [Environment]::SetEnvironmentVariable('ChocolateyInstall', $InstallationDirectory, 'Process')
    }
    & $chocInstallPS1 | Write-Debug

    Write-Verbose 'Ensuring chocolatey commands are on the path.'
    $chocoPath = [Environment]::GetEnvironmentVariable('ChocolateyInstall')
    if ($chocoPath -eq $null -or $chocoPath -eq '')
    {
        $chocoPath = "$env:ALLUSERSPROFILE\Chocolatey"
    }

    if (!(Test-Path ($chocoPath)))
    {
        $chocoPath = "$env:SYSTEMDRIVE\ProgramData\Chocolatey"
    }

    $chocoExePath = Join-Path $chocoPath 'bin'

    if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower()) -eq $false)
    {
        $env:Path = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
    }

    Write-Verbose 'Ensuring chocolatey.nupkg is in the lib folder'
    $chocoPkgDir = Join-Path $chocoPath 'lib\chocolatey'
    $nupkg = Join-Path $chocoPkgDir 'chocolatey.nupkg'
    $null = [System.IO.Directory]::CreateDirectory($chocoPkgDir)
    Copy-Item "$file" "$nupkg" -Force -ErrorAction SilentlyContinue

    if ($ChocoVersion = & "$chocoPath\choco.exe" -v)
    {
        Write-Verbose "Installed Chocolatey Version: $ChocoVersion"
    }
}
