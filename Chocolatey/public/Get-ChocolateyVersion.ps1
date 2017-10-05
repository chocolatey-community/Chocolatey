function Get-ChocolateyVersion {
    [CmdletBinding()]
    Param(
    )

    if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
        Throw "Chocolatey Software not found"
    }
    
    $ChocoArguments = @('-v')
    Write-Verbose "choco $($ChocoArguments -join ' ')"

    $CHOCO_OLD_MESSAGE = "Please run chocolatey /? or chocolatey help - chocolatey v"
    $versionOutput = (&$chocoCmd $ChocoArguments) -replace ([regex]::escape($CHOCO_OLD_MESSAGE))
    #remove other text to keep only the last line which should have the version
    $versionOutput = ($versionOutput -split '\r\n|\n|\r')[-1]
    Write-Verbose $versionOutput
    [version]($versionOutput)
}