<#
.SYNOPSIS
    Verify if a Chocolatey Package is installed locally

.DESCRIPTION
    Search and compare the Installed PackageName locally, and compare the provided property.
    The command return an object with the detailed properties, and a comparison between the installed version
    and the expected version.

.PARAMETER Name
    Exact name of the package to be testing against.

.PARAMETER Version
    Version expected of the package, or latest to compare against the latest version from a source.

.PARAMETER Source
    Source to compare the latest version against. It will retrieve the

.PARAMETER Credential
    Credential used with authenticated feeds. Defaults to empty.

.PARAMETER CacheLocation
    CacheLocation - Location for download cache, defaults to %TEMP% or value
    in chocolatey.config file.

.PARAMETER UpdateOnly
    Test if the package needs to be installed if absent.
    In Update Only mode, a package of lower version needs to be updated, but a package absent
    won't be installed.

.EXAMPLE
    Test-ChocolateyPackageIsInstalled -Name Chocolatey -Source https://chocolatey.org/api/v2

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsList
#>
function Test-ChocolateyPackageIsInstalled {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    param(
        [Parameter(
            Mandatory
            , ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Version,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        $Source,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [PSCredential]
        $Credential,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [System.String]
        $CacheLocation,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $UpdateOnly

    )

    Process {
        if (-not (Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found."
        }

        #if version latest verify against sources
        if (! ($InstalledPackages = @(Get-ChocolateyPackage -LocalOnly -Name $Name -Exact)) ) {
            Write-Verbose "Could not find Package $Name."
        }

        $SearchPackageParams = $PSBoundParameters
        $null = $SearchPackageParams.Remove('version')
        $null = $SearchPackageParams.Remove('UpdateOnly')

        if ($Version -eq 'latest') {
            $ReferenceObject = Get-ChocolateyPackage @SearchPackageParams -Exact
            if (!$ReferenceObject) {
                Throw "Latest version of Package $name not found. Verify that the sources are reachable and package exists."
            }
        }
        else {
            $ReferenceObject = [PSCustomObject]@{
                Name = $Name
            }
            if ($Version) { $ReferenceObject | Add-Member -MemberType NoteProperty -Name version -value $Version }
        }

        $PackageFound = $false
        $MatchingPackages = $InstalledPackages | Where-Object {
            Write-Debug "Testing $($_.Name) against $($ReferenceObject.Name)"
            if ($_.Name -eq $ReferenceObject.Name) {
                $PackageFound = $True
                Write-Debug "Package Found"

                if ((Compare-SemVerVersion $_.version $ReferenceObject.version) -in @('=', '>')) {
                    return $true
                }
                else {
                    return $false
                }
            }
        }

        if ($MatchingPackages) {
            Write-Verbose ("'{0}' packages match the given properties." -f $MatchingPackages.Count)
            $VersionGreaterOrEqual = $true
        }
        elseif ($PackageFound -and $UpdateOnly) {
            Write-Verbose "This package is installed with a lower version than specified."
            $VersionGreaterOrEqual = $false
        }
        elseif (!$PackageFound -and $UpdateOnly) {
            Write-Verbose "No packages match the selection, but no need to Install."
            $VersionGreaterOrEqual = $true
        }
        else {
            Write-Verbose "No packages match the selection and need Installing."
            $VersionGreaterOrEqual = $False
        }

        Write-Output ([PSCustomObject]@{
                PackagePresent        = $PackageFound
                VersionGreaterOrEqual = $VersionGreaterOrEqual
            })
    }
}