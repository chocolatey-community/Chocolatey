<#
.SYNOPSIS
List the packages from a source or installed on the local machine.

.DESCRIPTION
This command can list the packages available on the configured source or a specified one.
You can also retrieve the list of package installed locally.
Finally, you can also use this command to search for a specific package, and specific version.

.PARAMETER Name
Name or part of the name of the Package to search for, whether locally or from source(s).

.PARAMETER Version
Version of the package you're looking for.

.PARAMETER LocalOnly
Restrict the search to the installed package.

.PARAMETER IdOnly
Id Only - Only return Package Ids in the list results. Available in 0.1-0.6+.

.PARAMETER Prerelease
Prerelease - Include Prereleases? Defaults to false

.PARAMETER ApprovedOnly
ApprovedOnly - Only return approved packages - this option will filter
out results not from the community repository (https://chocolatey.org/packages). Available in 0.9.10+

.PARAMETER ByIdOnly
ByIdOnly - Only return packages where the id contains the search filter.
Available in 0.9.10+.

.PARAMETER IdStartsWith
IdStartsWith - Only return packages where the id starts with the search
filter. Available in 0.9.10+.

.PARAMETER NoProgress
Do Not Show Progress - Do not show download progress percentages.

.PARAMETER Exact
Exact - Only return packages with this exact name. Available in 0.9.10+.

.PARAMETER Source
Source - Source location for install. Can use special 'webpi' or 'windowsfeatures' sources. Defaults to sources.

.PARAMETER Credential
Credential used with authenticated feeds. Defaults to empty.

.PARAMETER CacheLocation
CacheLocation - Location for download cache, defaults to %TEMP% or value in chocolatey.config file.

.EXAMPLE
Get-ChocolateyPackage -LocalOnly chocolatey

.NOTES
https://github.com/chocolatey/choco/wiki/CommandsList
#>
function Get-ChocolateyPackage {
    [CmdletBinding()]
    Param(
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(
            , ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Version,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $LocalOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $IdOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $Prerelease,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $ApprovedOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $ByIdOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $IdStartsWith,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $NoProgress,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $Exact,

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

        $ChocoArguments = @('list', '-r')
        $paramKeys = [Array]::CreateInstance([string], $PSboundparameters.Keys.count)
        $PSboundparameters.Keys.CopyTo($paramKeys, 0)
        switch ($paramKeys) {
            'verbose' { $null = $PSBoundParameters.remove('Verbose') }
            'debug' { $null = $PSBoundParameters.remove('debug') }
            'Name' { $null = $PSBoundParameters.remove('Name') }
            'Exact' { $null = $PSBoundParameters.remove('Exact') }
        }

        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose "choco $($ChocoArguments -join ' ')"

        if ($ChocoArguments -contains '--verbose') {
            $ChocoArguments = [System.Collections.ArrayList]$ChocoArguments
            $ChocoArguments.remove('--verbose')
        }


        if ( $LocalOnly -and
            !$PSboundparameters.containsKey('Version') -and
            (($Name -and $Exact) -or ([string]::IsNullOrEmpty($Name)))
        ) {
            $CachePath = [io.path]::Combine($Env:ChocolateyInstall, 'cache', 'GetChocolateyPackageCache.xml')
            Write-Debug "Attempting to load list from cache at $CachePath"
            if ( (Test-Path $CachePath) -and
                (Get-Item $CachePath).LastWriteTime -gt ([datetime]::Now.AddSeconds(-60))
            ) {
                Write-Debug "Retrieving from cache at $CachePath"
                $UnfilteredResults = @(Import-Clixml -Path $CachePath)
            }
            elseif (($CachePath = [io.path]::Combine([System.IO.Path]::GetTempPath(), 'GetChocolateyPackageCache.xml')) -and
                (Test-Path $CachePath) -and
                (Get-Item $CachePath).LastWriteTime -gt ([datetime]::Now.AddSeconds(-60))
            ) {
                Write-Debug "Attempting to load list from USER cache at $CachePath"
                $UnfilteredResults = @(Import-Clixml -Path $CachePath)
            }
            else {
                Write-Debug "Running from command before caching"
                $ChocoListOutput = &$chocoCmd $ChocoArguments
                $UnfilteredResults = $ChocoListOutput | ConvertFrom-Csv -Delimiter '|' -Header 'Name', 'Version'
                $CacheFile = [io.fileInfo]$CachePath
                if (!(Test-path $CachePath)) {
                    Write-Debug "> $CachePath"
                    try {
                        $null = New-Item -Path $CacheFile.Directory -Name $CacheFile.Name -Value '' -Force -ErrorAction Stop
                    }
                    catch {
                        $CachePath = $CacheFile = [io.fileInfo](Join-Path ([System.IO.Path]::GetTempPath()) 'GetChocolateyPackageCache.xml')
                        Write-Debug "New Cache file at $CacheFile"
                        $null = New-Item -Path $CacheFile.Directory -Name $CacheFile.Name -Value '' -Force
                    }
                }

                $null = $UnfilteredResults | Export-Clixml -Path $CacheFile -Force -ErrorAction SilentlyContinue
            }

            $UnfilteredResults.Where{
                $( if ($Name) {$_.Name -eq $Name} else { $true })
            }
        }
        else {
            Write-Debug "Running from command without caching."
            $ChocoListOutput = &$chocoCmd $ChocoArguments $Name $( if ($Exact) { '--exact' } )
            $ChocoListOutput | ConvertFrom-Csv -Delimiter '|' -Header 'Name', 'Version'
        }
    }
}