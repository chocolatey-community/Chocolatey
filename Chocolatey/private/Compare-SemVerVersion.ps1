function Compare-SemVerVersion {
    [CmdletBinding()]
    [OutputType([char])]
    Param (

        [String]
        $ReferenceVersion,
        
        [String]
        $DifferenceVersion
    )

    $refVersion = Get-SemVerFromString -VersionString $ReferenceVersion
    $diffVersion = Get-SemVerFromString -VersionString $DifferenceVersion

    # Compare Version first
    if($refVersion.Version -eq $diffVersion.Version) {
        if($diffVersion.Prerelease -and !$refVersion.Prerelease) {
            '<'
        }
        elseif(!$diffVersion.Prerelease -and !$refVersion.Prerelease) {
            '='
        }
        elseif($refVersion.Prerelease -eq $diffVersion.Prerelease) {
            '='
        }
        else {
            $resultSoFar = '='
            foreach($index in 0..($refVersion.PrereleaseArray.count-1)) {
                $refId  = ($refVersion.PrereleaseArray[$index] -as [uint64])
                $diffId = ($diffVersion.PrereleaseArray[$index] -as [uint64])
                if($refId -and $diffId) {
                    if($refid -gt $diffId) { return '>'}
                    elseif($refId -lt $diffId) { return '<'}
                    else {
                        Write-Debug "Ref identifier at index = $index are equals, moving onto next"
                    }
                }
                else {
                    $refId = [char[]]$refVersion.PrereleaseArray[$index]
                    $diffId = [char[]]$diffVersion.PrereleaseArray[$index]
                    foreach($charIndex in 0..($refId.Count-1)) {
                        if([int]$refId[$charIndex] -gt [int]$diffId[$charIndex]) {
                            return '>'
                        }
                        elseif([int]$refId[$charIndex] -lt [int]$diffId[$charIndex]) {
                            return '<'
                        }

                        Write-Warning "$($refId.count) $($diffId.count)"
                        if($refId.count -eq $charIndex+1 -and $refId.count -lt $diffId.count) {
                            return '<'
                        }
                        elseif($diffId.count -eq $index+1 -and $refId.count -gt $diffId.count) {
                            return '>'
                        }
                    }
                }

                if($refVersion.PrereleaseArray.count -eq $index+1 -and $refVersion.PrereleaseArray.count -lt $diffVersion.PrereleaseArray.count) {
                    return '<'
                }
                elseif($diffVersion.PrereleaseArray.count -eq $index+1 -and $refVersion.PrereleaseArray.count -gt $diffVersion.PrereleaseArray.count) {
                    return '>'
                }
            } 
            return $resultSoFar          
        }
    }
    elseif ($refVersion.Version -gt $diffVersion.Version) {
        '>'
    }
    else {
        '<'
    }
}