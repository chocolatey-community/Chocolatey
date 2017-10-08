<#
.SYNOPSIS
chocolately installer work arounds. Main issue is use of write-host

.DESCRIPTION
chocolately installer work arounds. 
Main issue is use of write-host, although the version of this module prefers
the use of Write-Verbose or Debug.

.PARAMETER Object
Object to intercept and redirect to write host.

.PARAMETER NoNewLine
Do not end line with a \r\n

.PARAMETER ForegroundColor
The Use some custom colors is dropped.

.PARAMETER BackgroundColor
The Use some custom colors is dropped.

.EXAMPLE
#Don't do this
Write-Host "killing kittens"

.NOTES
General notes
#>
function Write-Host
{
    Param(
        [Parameter(Mandatory,Position = 0)]
        $Object,

        [Switch]
        $NoNewLine,

        [ConsoleColor]
        $ForegroundColor,

        [ConsoleColor]
        $BackgroundColor
    )
    #Redirecting Write-Host -> Write-Verbose. 
    Write-Verbose $Object
}