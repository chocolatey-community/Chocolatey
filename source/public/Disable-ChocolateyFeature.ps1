
<#
.SYNOPSIS
    Disable a Chocolatey Feature

.DESCRIPTION
    Allows you to disable a Chocolatey Feature usually accessed by choco feature disable -n=bob

.PARAMETER Name
    Name of the Chocolatey Feature to disable. Some are only available in the Chocolatey for business version.

.PARAMETER RunNonElevated
    Throws if the process is not running elevated. use -RunNonElevated if you really want to run
    even if the current shell is not elevated.

.EXAMPLE
    Disable-ChocolateyFeature -Name 'Bob'

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsFeature
#>
function Disable-ChocolateyFeature
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Feature')]
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

        if (-not (Get-ChocolateyFeature -Name $Name))
        {
            throw "Chocolatey Feature $Name cannot be found."
        }

        $ChocoArguments = @('feature', 'disable')
        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose -Message ('choco {0}' -f ($ChocoArguments -join ' '))

        if ($PSCmdlet.ShouldProcess($Env:COMPUTERNAME, "$chocoCmd $($ChocoArguments -join ' ')"))
        {
            &$chocoCmd $ChocoArguments | ForEach-Object -Process {
                Write-Verbose -Message ('{0}' -f $_)
            }
        }
    }
}
