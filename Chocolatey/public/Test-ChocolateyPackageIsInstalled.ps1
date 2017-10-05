function Test-ChocolateyPackageIsInstalled {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory
            ,ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [String]
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
        [String]
        $CacheLocation

    )

    Process {
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found"
        }
        
        #if version latest verify against sources
        if (! ($InstalledPackages += Get-ChocolateyPackage -LocalOnly -Name $Name) ) {
            Write-Verbose "Could not find Package $Name"
            return $false
        }

        $SearchPackageParams = $PSBoundParameters
        $null = $SearchPackageParams.Remove('version')

        if ($Version -eq 'latest') {
            $ReferenceObject = Get-ChocolateyPackage @SearchPackageParams -Exact
            if(!$ReferenceObject) {
                Throw "Latest version of Package $name not found. Verify that the sources are reachable."
            }
        }
        else {
            $ReferenceObject = [PSCustomObject]@{
                Name = $Name
            }
            if($Version) { $ReferenceObject | Add-Member -MemberType NoteProperty -Name version -value $Version }
        }
        $PackageFound = $false
        $MatchingPackages = $InstalledPackages | Where-Object {
            Write-Debug "Testing $($_.Name) against $($ReferenceObject.Name)"
            if($_.Name -eq $ReferenceObject.Name) {
                $PackageFound = $True;
                Write-Debug "Package Found"
                
                if ($_.version -ge $ReferenceObject.version) {
                    return $true
                }
                else {
                    return $false
                }
            }
        }
        if ($MatchingPackages) {
            Write-Verbose ("'{0}' packages match the given properties." -f $MatchingPackages.Count)
            Write-Output ([PSCustomObject]@{
                PackagePresent          =  $PackageFound
                VersionGreaterOrEqual   =  $True
            })
        }
        else {
            Write-Verbose "No packages match the selection."
            Write-Output ([PSCustomObject]@{
                PackagePresent          =  $PackageFound
                VersionGreaterOrEqual   =  $False
            })
        }
    }
}