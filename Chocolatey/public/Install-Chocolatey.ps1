<#
.SYNOPSIS
Install Chocolatey either from package or from a provided install script url.

.DESCRIPTION
This commmand lets you Install Chocolatey Package management either by using the
embedded Chocolatey package, or by specifying the URL for an install script.

.PARAMETER InstallDir
You can specify where Chocolatey will be installed. By default this will be 
$Env:ProgramData\Chocolatey.

.PARAMETER ChocoInstallScriptUrl
This settings default to the embeded version of Chocolatey, hence can be outdate
(but works offline), or you could specify the url to an install script, such as
the one provided by Chocolatey: http://chocolatey.org/install.ps1, ensuring you
will get the latest version available.

.EXAMPLE
Install-Chocolatey
#Will install the embeded package in the recommended location

.EXAMPLE
Install-Chocolatey -InstallDir C:\Chocolatey

.NOTES
When using the ChocoInstallScriptUrl parameter, setting up the proxy is not supported.
#>
function Install-Chocolatey {
    [CmdletBinding()]
    Param(
        [ValidateNotNullOrEmpty()]
        [string]
        $InstallDir = [io.path]::combine($Env:ProgramData,'chocolatey'),

        [string]
        $ChocoInstallScriptUrl
    )
    begin {
        #Resolve the Module base to find the Bin folder (whether module is merged or not)
        if(-not ($ModuleBase = $MyInvocation.Mycommand.Module.ModuleBase)) {
            $Modulebase= (Resolve-Path "$PSScriptRoot\..").Path
        }
        if (-not (Test-Path $InstallDir)) {
            Write-Verbose ('Creating install folder {0}' -f $InstallDir)
            mkdir -Force $InstallDir -ErrorAction Stop
        }
        # Default to Embedded package
        if (-not $ChocoInstallScriptUrl) { #or 'https://chocolatey.org/install.ps1'
            $ChocoInstallScriptUrl = "$modulebase\bin\Chocolatey\chocolatey.*\tools\chocolateyInstall.ps1"
        }
        else { #Or download an install script
            #As we're mainly targeting DSC, we expect v4+
            $InstallScriptFullName = [io.path]::combine($InstallDir,'install.ps1')
            Invoke-WebRequest -Uri $ChocoInstallScriptUrl -OutFile $InstallScriptFullName -UseBasicParsing
            $ChocoInstallScriptUrl = $InstallScriptFullName
        }
    }

    Process {
        Write-Verbose "Setting the ChocolateyInstall Environment variable for installation."
        [Environment]::SetEnvironmentVariable('ChocolateyInstall', $InstallDir, 'Machine')
        $Env:ChocolateyInstall = $InstallDir
        
        &  $ChocoInstallScriptUrl

        #refresh after install
        Write-Verbose 'Adding Choco to path'
        $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')   
        if ($env:path -notlike "*$InstallDir*") {
            $env:Path += ";$InstallDir"
        }

        Write-Verbose "Env:Path has $env:path"    
        #initialize Choco
        $null = Choco
        Write-Verbose 'Installation complete'
    }
}