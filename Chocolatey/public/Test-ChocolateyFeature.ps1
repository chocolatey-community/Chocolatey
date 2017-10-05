function Test-ChocolateyFeature {
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
        $Disabled
    )

    Process {
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found"
        }

        if (!($Feature = Get-ChocolateyFeature -Name $Name)) {
            Write-Warning "Chocolatey Feature $Name cannot be found."
            return $false
        }
        $Feature | Write-Verbose
        if ($Feature.enabled -eq !$Disabled.ToBool()) {
            Write-Verbose ("The Chocolatey Feature {0} is {1} as expected" -f $Name,(@('Disabled','Enabled')[([int]$Disabled.ToBool())]))
            return $true
        }
        else {
            Write-Verbose ("The Chocolatey Feature {0} is {1} NOT as expected" -f $Name,(@('Disabled','Enabled')[([int]$Disabled.ToBool())]))
            return $False
        }
    }
}