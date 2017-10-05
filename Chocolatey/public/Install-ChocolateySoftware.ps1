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
function Install-ChocolateySoftware {
    [CmdletBinding(
        DefaultParameterSetName = 'FromFeedUrl'
    )]
    Param(
        # To target a different url for chocolatey.nupkg, please set $env:chocolateyDownloadUrl = 'full url to nupkg file'
        [Parameter(
            ParameterSetName = 'FromPackageUrl'
        )]
        [uri]
        $ChocolateyPackageUrl,

        # To use a nuget feed (odata) to search the package from, provide the API endpoint url (not frontend)
        [Parameter(
            ParameterSetName = 'FromFeedUrl'
        )]
        [uri]
        $PackageFeedUrl = 'https://chocolatey.org/api/v2',

        [string]
        $Version,

        [string]
        $ChocoTempDir,

        [uri]
        $ProxyLocation,

        [pscredential]
        $ProxyCredential,

        # To bypass the use of any proxy, please set chocolateyIgnoreProxy = 'true'
        [switch]
        $IgnoreProxy
    )

    if($PSVersionTable.PSVersion.Major -lt 4) {
        Repair-PowerShellOutputRedirectionBug
    }

    # Attempt to set highest encryption available for SecurityProtocol.
    # PowerShell will not set this by default (until maybe .NET 4.6.x). This
    # will typically produce a message for PowerShell v2 (just an info
    # message though)
    try {
        # Set TLS 1.2 (3072), then TLS 1.1 (768), then TLS 1.0 (192), finally SSL 3.0 (48)
        # Use integers because the enumeration values for TLS 1.2 and TLS 1.1 won't
        # exist in .NET 4.0, even though they are addressable if .NET 4.5+ is
        # installed (.NET 4.5 is an in-place upgrade).
        [System.Net.ServicePointManager]::SecurityProtocol = 3072 -bor 768 -bor 192 -bor 48
    }
    catch {
        Write-Warning 'Unable to set PowerShell to use TLS 1.2 and TLS 1.1 due to old .NET Framework installed. If you see underlying connection closed or trust errors, you may need to do one or more of the following: (1) upgrade to .NET Framework 4.5+ and PowerShell v3, (2) specify internal Chocolatey package location (set $env:chocolateyDownloadUrl prior to install or host the package internally), (3) use the Download + PowerShell method of install. See https://chocolatey.org/install for all install options.'
    }

    if (![string]::IsNullOrEmpty($ChocolateyPackageUrl)){
        Write-Verbose "Downloading Chocolatey from : $ChocolateyPackageUrl"
        $url = $ChocolateyPackageUrl
    }

    if ($PackageFeedUrl -and ![string]::IsNullOrEmpty($Version)){
        Write-Verbose "Downloading specific version of Chocolatey: $chocolateyVersion"
        $url = "$PackageFeedUrl/package/chocolatey/$Version"
    }
    elseif($PSCmdlet.ParameterSetName -eq 'FromFeedUrl' -and (![string]::IsNullOrEmpty($PackageFeedUrl))) {
        $url = $PackageFeedUrl
    }
    else {
        $url = 'https://chocolatey.org/api/v2'
    }

    if ($null -eq $env:TEMP) {
        $env:TEMP = Join-Path $Env:SYSTEMDRIVE 'temp'
    }

    $tempDir = [io.path]::Combine($Env:TEMP,'chocolatey','chocInstall')
    if (![System.IO.Directory]::Exists($tempDir)) {
        [void][System.IO.Directory]::CreateDirectory($tempDir)
    }
    $file = Join-Path $tempDir "chocolatey.zip"

    Write-Verbose "Getting latest version of the Chocolatey package for download."
    $url = "$url/Packages()?`$filter=((Id%20eq%20%27chocolatey%27)%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion"
    [xml]$result = Get-RemoteString $url
    $url = $result.feed.entry.content.src

    # Download the Chocolatey package
    Write-Verbose "Getting Chocolatey from $url."
    $null = Get-RemoteFile $url $file

    # unzip the package
    Write-Verbose "Extracting $file to $tempDir..."

    if ($PSVersionTable.PSVersion.Major -ge 5) {
        Expand-Archive -Path "$file" -DestinationPath "$tempDir" -Force
    }
    else {
        try {
            $shellApplication = new-object -com shell.application
            $zipPackage = $shellApplication.NameSpace($file)
            $destinationFolder = $shellApplication.NameSpace($tempDir)
            $destinationFolder.CopyHere($zipPackage.Items(),0x10)
        }
        catch {
            throw "Unable to unzip package using built-in compression. Error: `n $_"
        }
    }

    # Call chocolatey install
    Write-Verbose "Installing chocolatey on this machine"
    $chocInstallPS1 = [io.path]::combine($tempDir,'tools','chocolateyInstall.ps1')

    & $chocInstallPS1

    Write-Verbose 'Ensuring chocolatey commands are on the path'
    $chocoPath = [Environment]::GetEnvironmentVariable('ChocolateyInstall')
    if ($chocoPath -eq $null -or $chocoPath -eq '') {
        $chocoPath = "$env:ALLUSERSPROFILE\Chocolatey"
    }

    if (!(Test-Path ($chocoPath))) {
        $chocoPath = "$env:SYSTEMDRIVE\ProgramData\Chocolatey"
    }

    $chocoExePath = Join-Path $chocoPath 'bin'

    if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower()) -eq $false) {
        $env:Path = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine)
    }

    Write-Verbose 'Ensuring chocolatey.nupkg is in the lib folder'
    $chocoPkgDir = Join-Path $chocoPath 'lib\chocolatey'
    $nupkg = Join-Path $chocoPkgDir 'chocolatey.nupkg'

    if (![System.IO.Directory]::Exists($chocoPkgDir)) { 
        [System.IO.Directory]::CreateDirectory($chocoPkgDir)
    }
    Copy-Item "$file" "$nupkg" -Force -ErrorAction SilentlyContinue
}