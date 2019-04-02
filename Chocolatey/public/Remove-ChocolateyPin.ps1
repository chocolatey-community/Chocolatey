<#
.SYNOPSIS
    Remove a Pin from a Chocolatey Package

.DESCRIPTION
    Allows you to remove a pinned Chocolatey Package like choco pin remove -n=packagename

.PARAMETER Name
    Name of the Chocolatey Package to remove the pin.

.PARAMETER Version
    This allows to unpin a Chocolatey Package.

.EXAMPLE
    Remove-ChocolateyPin -Name 'PackageName' -Version '1.0.0'

.NOTES
    https://chocolatey.org/docs/commands-pin
#>
function Remove-ChocolateyPin {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]
    Param(
        [Parameter(
            Mandatory
            , ValueFromPipelineByPropertyName
        )]
        [Alias('Package')]
        [System.String]
        $Name,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [System.String]
        $Version
    )

    Process {
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found"
        }

        $ChocoArguments = @('pin', 'remove', '-r')
        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose "choco $($ChocoArguments -join ' ')"

        if ($PSCmdlet.ShouldProcess("$Name $Version", "Remove Pin")) {
            &$chocoCmd $ChocoArguments | Write-Verbose

            # LASTEXITCODE is always 0 unless point an existing version (0 when remove but already removed)
            if ($LASTEXITCODE -ne 0) {
                Throw ("Error when trying to Remove Pin for {0}.`r`n {1}" -f "$Name $Version", ($output -join "`r`n"))
            }
            else {
                $output | Write-Verbose
            }
        }
    }
}
