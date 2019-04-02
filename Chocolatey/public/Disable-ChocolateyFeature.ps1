<#
.SYNOPSIS
    Disable a Chocolatey Feature

.DESCRIPTION
    Allows you to disable a Chocolatey Feature usually accessed by choco feature disable -n=bob

.PARAMETER Name
    Name of the Chocolatey Feature to disable. Some are only available in the Chocolatey for business version.

.PARAMETER NoProgress
    This allows to reduce the output created by the Chocolatey Command.

.EXAMPLE
    Disable-ChocolateyFeature -Name 'Bob'

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsFeature
#>
function Disable-ChocolateyFeature {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory
            ,ValueFromPipelineByPropertyName
        )]
        [Alias('Feature')]
        [String]
        $Name,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $NoProgress

    )

    Process {
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found"
        }

        if (!(Get-ChocolateyFeature -Name $Name)) {
            Throw "Chocolatey Feature $Name cannot be found."
        }

        $ChocoArguments = @('feature','disable')
        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose "choco $($ChocoArguments -join ' ')"

        &$chocoCmd $ChocoArguments | Write-Verbose
    }
}