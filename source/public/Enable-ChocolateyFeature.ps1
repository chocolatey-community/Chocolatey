<#
.SYNOPSIS
    Disable a Chocolatey Feature

.DESCRIPTION
    Allows you to enable a Chocolatey Feature usually accessed by choco feature enable -n=bob

.PARAMETER Name
    Name of the Chocolatey Feature to disable

.PARAMETER NoProgress
    This allows to reduce the output created by the Chocolatey Command.

.EXAMPLE
    Enable-ChocolateyFeature -Name 'MyChocoFeatureName'

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsFeature
#>
function Enable-ChocolateyFeature
{
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
            , ValueFromPipelineByPropertyName
        )]
        [Alias('Feature')]
        [System.String]
        $Name,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $NoProgress
    )

    process
    {
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue))
        {
            throw "Chocolatey Software not found."
        }

        if (!(Get-ChocolateyFeature -Name $Name))
        {
            throw "Chocolatey Feature $Name cannot be found."
        }

        $ChocoArguments = @('feature', 'enable')
        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose "choco $($ChocoArguments -join ' ')"

        &$chocoCmd $ChocoArguments | Write-Verbose
    }
}
