<#
.SYNOPSIS
    Add a Pin to a Chocolatey Package

.DESCRIPTION
    Allows you to pin a Chocolatey Package like choco pin add -n=packagename

.PARAMETER Name
    Name of the Chocolatey Package to pin.
    The Package must be installed beforehand.

.PARAMETER Version
    This allows to pin a specific Version of a Chocolatey Package.
    The Package with the Version to pin must be installed beforehand.

.EXAMPLE
    Add-ChocolateyPin -Name 'PackageName'

.EXAMPLE
    Add-ChocolateyPin -Name 'PackageName' -Version '1.0.0'

.NOTES
    https://chocolatey.org/docs/commands-pin
#>
function Add-ChocolateyPin {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    Param(
        [Parameter(
            Mandatory
            ,ValueFromPipelineByPropertyName
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
            Throw "Chocolatey Software not found."
        }

        if (!(Get-ChocolateyPackage -Name $Name)) {
            Throw "Chocolatey Package $Name cannot be found."
        }

        $ChocoArguments = @('pin','add','-r')
        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose "choco $($ChocoArguments -join ' ')"

        if ($PSCmdlet.ShouldProcess("$Name $Version", "Add Pin"))
        {
            $Output = &$chocoCmd $ChocoArguments

            # LASTEXITCODE is always 0 unless point an existing version (0 when remove but already removed)
            if ($LASTEXITCODE -ne 0) {
                Throw ("Error when trying to add Pin for {0}.`r`n {1}" -f "$Name $Version", ($output -join "`r`n"))
            }
            else {
                $output | Write-Verbose
            }
        }
    }
}
