<#
.SYNOPSIS
    Enable a Source set in the Chocolatey Config

.DESCRIPTION
    Lets you Enable an existing source from the Chocolatey Config.
    The equivalent Choco command is Choco source enable -n=sourcename

.PARAMETER Name
    Name of the Chocolatey source to Disable

.PARAMETER NoProgress
    This allows to reduce the output created by the Chocolatey Command.

.EXAMPLE
    Enable-ChocolateySource -Name 'chocolatey'

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsSource
#>
function Enable-ChocolateySource
{
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
            , ValueFromPipelineByPropertyName
        )]
        [System.String]
        $Name,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $NoProgress

    )

    process
    {
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue))
        {
            Throw "Chocolatey Software not found."
        }

        if (!(Get-ChocolateySource -id $Name))
        {
            Throw "Chocolatey Source $Name cannot be found. You can Register it using Register-ChocolateySource."
        }

        $ChocoArguments = @('source', 'enable')
        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose "choco $($ChocoArguments -join ' ')"

        &$chocoCmd $ChocoArguments | Write-Verbose
    }
}
