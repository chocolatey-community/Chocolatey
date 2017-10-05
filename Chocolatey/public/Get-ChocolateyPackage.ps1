function Get-ChocolateyPackage {
    [CmdletBinding()]
    Param(
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(
            ,ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Version,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $LocalOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $IdOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $Prerelease,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $ApprovedOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $ByIdOnly,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $IdStartsWith,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $NoProgress,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [switch]
        $Exact,
        
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        $Source,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [PSCredential]
        $Credential,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [String]
        $CacheLocation

    )

    Process {
        if (-not ($chocoCmd = Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found"
        }
        
        $ChocoArguments = @('list',$Name)
        if ($PSBoundParameters.ContainsKey('name')) {
            $null = $PSBoundParameters.remove('Name')
        }
        $ChocoArguments += Get-ChocolateyDefaultArgument @PSBoundParameters
        Write-Verbose "choco $($ChocoArguments -join ' ')"

        if ($ChocoArguments -contains '--verbose') {
            $ChocoArguments = [System.Collections.ArrayList]$ChocoArguments
            $ChocoArguments.remove('--verbose')
        }
        $ChocoListOutput = &$chocoCmd $ChocoArguments

        $ChocoListOutput | Foreach-Object {
            #line should be Name,version,approved,Description
            $SplittedLine = $_.split(' ',4)
            if($SplittedLine[1] -as [version]){
                $package = [PSCustomObject]@{
                    PSTypeName = 'Chocolatey.Package'
                    Name       = $SplittedLine[0]
                    Version    = $SplittedLine[1]
                }
                if(!$LocalOnly) {
                    $Package | add-member -MemberType NoteProperty -Name Description -value $SplittedLine[3]
                    $Package | add-member -MemberType NoteProperty -Name Approved -value $(
                        if($SplittedLine[2] -eq '[Approved]'){ $true } else { $false }
                    )
                }
                $Package
            }
            
        }
    }
}