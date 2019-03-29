
function Get-ChocolateyPin {
    [CmdletBinding()]
    Param(
        [Parameter(
            ValueFromPipeline
            ,ValueFromPipelineByPropertyName
        )]
        [string[]]
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
        $ChocoPinListOutput = $ChocoPinListOutput | ConvertFrom-Csv -Delimiter '|' -Header 'Name','Version'
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
            PSTypeName  = 'Chocolatey.Pin'
            Name        = $Pin.Name
            Version     = $Pin.Version
        }
    }
}
