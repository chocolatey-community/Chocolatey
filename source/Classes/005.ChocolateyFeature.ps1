
<#
    .SYNOPSIS
        The `ChocolateyFeature` DSC resource is used to enable or disable features.

    .DESCRIPTION
        Chocolatey configuration lets you enable or disabled features, but while some are
        set by defaults.
        This resources lets you enable or disable a feature, but also tells you if it's been
        set or just left as default.

    .PARAMETER Ensure
        Indicate whether the Chocolatey feature should be enabled or disabled on the system.

    .PARAMETER Name
        Name - the name of the feature.

    .EXAMPLE
        Invoke-DscResource -ModuleName Chocolatey -Name ChocolateyFeature -Method Get -Property @{
            Ensure  = 'Absent'
            Name    = 'showDownloadProgress'
        }

        # This example shows how to disable the feature showDownloadProgress using Invoke-DscResource.
#>
[DscResource()]
class ChocolateyFeature
{
    [DscProperty()]
    [Ensure] $Ensure = 'Present'

    [DscProperty(Key)]
    [string] $Name

    [DscProperty(NotConfigurable)]
    [ChocolateyReason[]] $Reasons

    [ChocolateyFeature] Get()
    {
        $currentState = [ChocolateyFeature]::new()
        $currentState.Name = $this.Name

        try
        {
            $feature = Get-ChocolateyFeature -Name $this.Name
        }
        catch
        {
            Write-Verbose -Message ('Exception Caught:' -f $_)
            $feature = $null
            $currentState.Reasons += @{
                code = 'ChocolateySource:ChocolateySource:ChocolateyError'
                phrase = ('Error: {0}.' -f $_)
            }
        }

        if ($null -eq $feature)
        {
            $currentState.Ensure = 'Absent'
            $currentState.Reasons += @{
                code = 'ChocolateyFeature:ChocolateyFeature:FeatureNotFound'
                phrase = ('The feature ''{0}'' was not found.' -f $this.Name)
            }
        }
        elseif ($feature.enabled -and $this.Ensure -eq 'Present')
        {
            $currentState.Ensure = 'Present'
            $currentState.Reasons += @{
                code = 'ChocolateyFeature:ChocolateyFeature:FeaturePresentCompliant'
                phrase = ('The feature ''{0}'' is enabled as expected. Set Explicitly is {1}.' -f $this.Name, $feature.setExplicitly)
            }
        }
        elseif ($feature.enabled -and $this.Ensure -eq 'Absent')
        {
            $currentState.Ensure = 'Present'
            $currentState.Reasons += @{
                code = 'ChocolateyFeature:ChocolateyFeature:FeatureShouldBeDisabled'
                phrase = ('The feature ''{0}'' is enabled while it''s expected to be Absent. Set Explicitly is {1}.' -f $this.Name, $feature.setExplicitly)
            }
        }
        elseif ($false -eq $feature.enabled -and $this.Ensure -eq 'Absent')
        {
            $currentState.Ensure = 'Absent'
            $currentState.Reasons += @{
                code = 'ChocolateyFeature:ChocolateyFeature:FeatureAbsentCompliant'
                phrase = ('The feature ''{0}'' is disabled as expected. Set Explicitly is {1}.' -f $this.Name, $feature.setExplicitly)
            }
        }
        elseif ($false -eq $feature.enabled -and $this.Ensure -eq 'Present')
        {
            $currentState.Ensure = 'Absent'
            $currentState.Reasons += @{
                code = 'ChocolateyFeature:ChocolateyFeature:FeatureShouldBeEnabled'
                phrase = ('The feature ''{0}'' is disabled as expected. Set Explicitly is {1}.' -f $this.Name, $feature.setExplicitly)
            }
        }

        return $currentState
    }

    [bool] Test()
    {
        $currentState = $this.Get()
        $currentState.Reasons.code.Where{
            $_ -notmatch 'Compliant$'
        }

        if ($currentState.count -eq 0)
        {
            return $true
        }
        else
        {
            return $false
        }
    }

    [void] Set()
    {
        $currentState = $this.Get()

        switch ($currentState.Reasons.code)
        {
            'FeatureShouldBeDisabled'
            {
                # Disable the feature
                Disable-ChocolateyFeature -Name $this.Name
            }

            'FeatureShouldBeEnabled'
            {
                # Enable the feature
                Enable-ChocolateyFeature -Name $this.Name
            }
        }
    }
}
