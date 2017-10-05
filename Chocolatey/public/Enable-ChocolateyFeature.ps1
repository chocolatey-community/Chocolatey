function Enable-ChocolateyFeature {
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
        
        $ChocoArguments = @('feature','enable')
        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose "choco $($ChocoArguments -join ' ')"

        &$chocoCmd $ChocoArguments | Write-Verbose
    }
}