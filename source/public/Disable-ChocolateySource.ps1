
<#
.SYNOPSIS
    Disable a Source set in the Chocolatey Config

.DESCRIPTION
    Lets you disable an existing source.
    The equivalent Choco command is Choco source disable -n=sourcename

.PARAMETER Name
    Name of the Chocolatey source to Disable

.PARAMETER NoProgress
    This allows to reduce the output created by the Chocolatey Command.

.EXAMPLE
    Disable-ChocolateySource -Name chocolatey

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsSource
#>
function Disable-ChocolateySource
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
        [Switch]
        $NoProgress
    )

    process
    {
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue))
        {
            throw "Chocolatey Software not found."
        }

        if (!(Get-ChocolateySource -Name $Name))
        {
            throw "Chocolatey Source $Name cannot be found. You can Register it using Register-ChocolateySource."
        }

        $ChocoArguments = @('source', 'disable')
        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose "choco $($ChocoArguments -join ' ')"

        &$chocoCmd $ChocoArguments | Write-Verbose
    }
}
