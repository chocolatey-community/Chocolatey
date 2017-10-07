<# 
.SYNOPSIS
Fix for PS2/3

.DESCRIPTION
PowerShell v2/3 caches the output stream. Then it throws errors due
to the FileStream not being what is expected. Fixes "The OS handle's
position is not what FileStream expected. Do not use a handle
simultaneously in one FileStream and in Win32 code or another
FileStream."

.EXAMPLE
Repair-PowerShellOutputRedirectionBug

#>
function Repair-PowerShellOutputRedirectionBug {
    [CmdletBinding()]
    Param(

    )
    
    if($PSVersionTable.PSVersion.Major -lt 4) {
        return
    }

    try{
        # http://www.leeholmes.com/blog/2008/07/30/workaround-the-os-handles-position-is-not-what-filestream-expected/ plus comments
        $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
        $objectRef = $host.GetType().GetField("externalHostRef", $bindingFlags).GetValue($host)
        $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetProperty"
        $consoleHost = $objectRef.GetType().GetProperty("Value", $bindingFlags).GetValue($objectRef, @())
        [void] $consoleHost.GetType().GetProperty("IsStandardOutputRedirected", $bindingFlags).GetValue($consoleHost, @())
        $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
        $field = $consoleHost.GetType().GetField("standardOutputWriter", $bindingFlags)
        $field.SetValue($consoleHost, [Console]::Out)
        [void] $consoleHost.GetType().GetProperty("IsStandardErrorRedirected", $bindingFlags).GetValue($consoleHost, @())
        $field2 = $consoleHost.GetType().GetField("standardErrorWriter", $bindingFlags)
        $field2.SetValue($consoleHost, [Console]::Error)
    }
    catch {
        Write-Warning "Unable to apply redirection fix."
    }
}