
<#
.SYNOPSIS
    Disable a Source set in the Chocolatey Config

.DESCRIPTION
    Lets you disable an existing source.
    The equivalent Choco command is Choco source disable -n=sourcename

.PARAMETER Name
    Name of the Chocolatey source to Disable

.PARAMETER RunNonElevated
    Throws if the process is not running elevated. use -RunNonElevated if you really want to run
    even if the current shell is not elevated.

.EXAMPLE
    Disable-ChocolateySource -Name chocolatey

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsSource
#>
function Disable-ChocolateySource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    [CmdletBinding()]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $Name,

        [Parameter(DontShow)]
        [switch]
        $RunNonElevated = $(Assert-ChocolateyIsElevated)
    )

    process
    {
        if (-not ($chocoCmd = @(Get-Command 'choco.exe' -CommandType 'Application' -ErrorAction 'SilentlyContinue')[0]))
        {
            throw "Chocolatey Software not found."
        }

        if (-not (Get-ChocolateySource -Name $Name))
        {
            throw "Chocolatey Source $Name cannot be found. You can Register it using Register-ChocolateySource."
        }

        $ChocoArguments = @('source', 'disable')
        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose -Message ('choco {0}' -f ($ChocoArguments -join ' '))

        &$chocoCmd $ChocoArguments | ForEach-Object -Process {
            Write-Verbose -Message ('{0}' -f $_)
        }
    }
}
