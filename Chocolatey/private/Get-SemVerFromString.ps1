function Get-SemVerFromString {
    [CmdletBinding()]
    [OutputType([PSobject])]
    
    Param (
        [String]
        $VersionString
    )

    # Based on SemVer 2.0 but adding Revision (common in .Net/NuGet/Chocolatey packages) https://semver.org
    if($VersionString -notmatch '-') {
        [System.Version]$version, $BuildMetadata = $VersionString -split '\+',2
    }
    else {
        [System.Version]$version, [String]$Tag = $VersionString -split '-',2
        $PreRelease, $BuildMetadata  =  $Tag -split '\+',2
    }

    $PreReleaseArray = $PreRelease -split '\.'

    [psobject]@{
        PSTypeName      = 'Package.Version'
        Version         = $version
        Prerelease      = $PreRelease
        Metadata        = $BuildMetadata
        PrereleaseArray = $PreReleaseArray
    }
}