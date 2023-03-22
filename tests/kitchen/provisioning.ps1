#!/usr/bin/env pwsh
$ProgressPreference = 'SilentlyContinue'

$PSVersionTable

$psget = Import-Module -Name PowerShellget -PassThru
$psget.ModuleBase

if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted')
{
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

# Install-Module -Name PSDesiredStateConfiguration -RequiredVersion 2.0.6 -Confirm:$false
# Import-Module -Name PSDesiredStateConfiguration -MinimumVersion 2.0 -PassThru
# Enable-ExperimentalFeature -Name PSDesiredStateConfiguration.InvokeDscResource -Confirm:$false

Install-Module -Name GuestConfiguration -AllowPrerelease
Import-Module -Name GuestConfiguration
