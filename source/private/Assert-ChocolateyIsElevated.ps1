function Assert-ChocolateyIsElevated
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        #
    )

    if ([Security.Principal.WindowsPrincipal]::New([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Write-Verbose -Message 'This process is running elevated.'
    }
    else
    {
        throw 'This command must be ran elevated.'
    }
}
