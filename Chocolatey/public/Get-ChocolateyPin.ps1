<#
.SYNOPSIS
    Gets the pinned Chocolatey Packages.

.DESCRIPTION
    This command gets the pinned Chocolatey Packages, and returns
    the Settings available from there.

.PARAMETER Name
    Name of the Packages when retrieving a single one or a specific list.
    It defaults to returning all Packages available in the config file.

.EXAMPLE
    Get-ChocolateyPin -Name packageName

.NOTES
    https://chocolatey.org/docs/commands-pin
#>
function Get-ChocolateyPin {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline
            ,ValueFromPipelineByPropertyName
        )]
        [System.String[]]
        $Name = '*'
    )

    if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
        Throw "Chocolatey Software not found"
    }

    # Prepare the arguments for `choco pin list -r`
    $ChocoArguments = @('pin', 'list', '-r')

    Write-Verbose "choco $($ChocoArguments -join ' ')"

    # Stop here if the list is empty
    if (-Not ($ChocoPinListOutput = &$chocoCmd $ChocoArguments)) {
        return
    }
    else {
        Write-Verbose ("Found {0} Packages" -f $ChocoPinListOutput.count)
        # Convert the list to objects
        $ChocoPinListOutput = $ChocoPinListOutput | ConvertFrom-Csv -Delimiter '|' -Header 'Name', 'Version'
    }

    if ($Name -ne '*') {
        Write-Verbose 'Filtering Pinned Packages'
        $ChocoPinListOutput = $ChocoPinListOutput | Where-Object { $_.Name -in $Name }
    }
    else {
        Write-Verbose 'Returning all Pinned Packages'
    }

    foreach ($Pin in $ChocoPinListOutput) {
        [PSCustomObject]@{
            PSTypeName = 'Chocolatey.Pin'
            Name       = $Pin.Name
            Version    = $Pin.Version
        }
    }
}
