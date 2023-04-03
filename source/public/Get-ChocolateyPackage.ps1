
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
function Get-ChocolateyPackage
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(
            , ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Version,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $LocalOnly,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $IdOnly,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $Prerelease,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Switch]
        $ApprovedOnly,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $ByIdOnly,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Switch]
        $IdStartsWith,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $NoProgress,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $Exact,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        $Source,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [PSCredential]
        $Credential,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $CacheLocation
    )

    process
    {
        if (-not ($chocoCmd = @(Get-Command 'choco.exe' -CommandType 'Application' -ErrorAction 'SilentlyContinue')[0]))
        {
            throw "Chocolatey Software not found."
        }

        $ChocoArguments = @('list', '-r')
        $paramKeys = [Array]::CreateInstance([string], $PSboundparameters.Keys.count)
        $PSboundparameters.Keys.CopyTo($paramKeys, 0)
        switch ($paramKeys)
        {
            'verbose'
            {
                $null = $PSBoundParameters.remove('Verbose')
            }
            'debug'
            {
                $null = $PSBoundParameters.remove('debug')
            }
            'Name'
            {
                $null = $PSBoundParameters.remove('Name')
            }
            'Exact'
            {
                $null = $PSBoundParameters.remove('Exact')
            }
        }

        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose "choco $($ChocoArguments -join ' ')"

        if ($ChocoArguments -contains '--verbose')
        {
            $ChocoArguments = [System.Collections.ArrayList]$ChocoArguments
            $ChocoArguments.remove('--verbose')
        }

        if ( $LocalOnly -and
            !$PSboundparameters.containsKey('Version') -and
            (($Name -and $Exact) -or ([string]::IsNullOrEmpty($Name)))
        )
        {
            $chocoInstallPath = Get-ChocolateyInstallPath -ErrorAction 'Stop'
            $cachePath = [io.path]::Combine($chocoInstallPath, 'cache', 'GetChocolateyPackageCache.xml')
            try
            {
                if (-not (Test-Path -Path $CacheFolder))
                {
                    $null = New-Item -Type Directory -Path $CacheFolder -Force -ErrorAction Stop
                }
                if (Test-Path -Path $CachePath)
                {
                    $CachedFile = Get-Item $CachePath
                }

                [io.file]::OpenWrite($CachePath).close()
                $CacheAvailable = $true
            }
            catch
            {
                Write-Debug "Unable to write to cache $CachePath, caching unavailable."
                $CacheAvailable = $false
            }

            if ( $CacheAvailable -and $CachedFile -and
                $CachedFile.LastWriteTime -gt ([datetime]::Now.AddSeconds(-60))
            )
            {
                Write-Debug "Retrieving from cache at $CachePath."
                $UnfilteredResults = @(Import-Clixml -Path $CachePath)
                Write-Debug "Loaded $($UnfilteredResults.count) from cache."
            }
            else
            {
                Write-Debug "Running command (before caching)."
                $ChocoListOutput = &$chocoCmd $ChocoArguments
                Write-Debug "$chocoCmd $($ChocoArguments -join ' ')"
                $UnfilteredResults = $ChocoListOutput | ConvertFrom-Csv -Delimiter '|' -Header 'Name', 'Version'
                $CacheFile = [io.fileInfo]$CachePath

                if ($CacheAvailable)
                {
                    try
                    {
                        $null = $UnfilteredResults | Export-Clixml -Path $CacheFile -Force -ErrorAction 'Stop'
                        Write-Debug "Unfiltered list cached at $CacheFile."
                    }
                    catch
                    {
                        Write-Debug "Error Creating the cache at $CacheFile."
                    }
                }
            }

            $UnfilteredResults | Where-Object {
                $( if ($Name)
                    {
                        $_.Name -eq $Name
                    }
                    else
                    {
                        $true
                    })
            }
        }
        else
        {
            Write-Debug "Running from command without caching."
            $ChocoListOutput = &$chocoCmd $ChocoArguments $Name $( if ($Exact)
                {
                    '--exact'
                } )
            $ChocoListOutput | ConvertFrom-Csv -Delimiter '|' -Header 'Name', 'Version'
        }
    }
}
