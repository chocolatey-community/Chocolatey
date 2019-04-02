<#
.SYNOPSIS
    Set or unset a Chocolatey Setting

.DESCRIPTION
    Allows you to set or unset the value of a Chocolatey setting usually accessed by choco config set -n=bob value

.PARAMETER Name
    Name (or setting) of the Chocolatey setting to modify

.PARAMETER Value
    Value to be given on the setting. This is not available when the switch -Unset is used.

.PARAMETER Unset
    Unset the setting, returning to the Chocolatey defaults.

.EXAMPLE
    Set-ChocolateySetting -Name 'cacheLocation' -value 'C:\Temp\Choco'

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsConfig
#>
function Set-ChocolateySetting {
    [CmdletBinding(
        SupportsShouldProcess
        ,ConfirmImpact='Low'
    )]
    [OutputType([Void])]
    param(
        [Parameter(
            Mandatory
            ,ValueFromPipelineByPropertyName
        )]
        [Alias('Setting')]
        [System.String]
        $Name,

        [Parameter(
            Mandatory
            ,ValueFromPipelineByPropertyName
            ,ParameterSetName = 'Set'
        )]
        [AllowEmptyString()]
        [System.String]
        $Value,

        [Parameter(
            ValueFromPipelineByPropertyName
            ,ParameterSetName = 'Unset'
        )]
        [switch]
        $Unset
    )

    Process {
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found."
        }

        $ChocoArguments = @('config')
        #Removing PSBoundParameters that could impact Chocolatey's "choco config set" command
        foreach ($key in @([System.Management.Automation.Cmdlet]::CommonParameters + [System.Management.Automation.Cmdlet]::OptionalCommonParameters)) {
            if ($PSBoundParameters.ContainsKey($key)) {
                $null = $PSBoundParameters.remove($key)
            }
        }

        if ($Unset -or [string]::IsNullOrEmpty($Value)) {
            if ($PSBoundParameters.ContainsKey('value')) { $null = $PSBoundParameters.Remove('Value') }
            $null = $PSBoundParameters.remove('unset')
            $ChocoArguments += 'unset'
        }
        else {
            $PSBoundParameters['Value'] = $ExecutionContext.InvokeCommand.ExpandString($Value).TrimEnd(@('/','\'))
            $ChocoArguments += 'set'
        }
        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose "choco $($ChocoArguments -join ' ')"

        if ($PSCmdlet.ShouldProcess($Env:COMPUTERNAME,"$chocoCmd $($ChocoArguments -join ' ')")) {
            $cmdOut = &$chocoCmd $ChocoArguments
        }

        if ($cmdOut) {
            Write-Verbose "$($cmdOut | Out-String)"
        }
    }
}