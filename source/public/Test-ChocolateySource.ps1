<#
.SYNOPSIS
    Verify the source settings matches the given parameters.

.DESCRIPTION
    This command compares the properties of the source found by name, with the parameters given.

.PARAMETER Name
    Name - the name of the source to find for comparison.

.PARAMETER Source
    Source - The source. This can be a folder/file share or an http location.
    If it is a url, it will be a location you can go to in a browser and
    it returns OData with something that says Packages in the browser,
    similar to what you see when you go to https://chocolatey.org/api/v2/.
    Defaults to empty.

.PARAMETER Disabled
    Test whether the source to is registered but disabled.
    By default it checks if enabled.

.PARAMETER BypassProxy
    Bypass Proxy - Is this source explicitly bypass any explicitly or
    system configured proxies? Defaults to false. Available in 0.10.4+.

.PARAMETER SelfService
    Is Self-Service ? - Is this source be allowed to be used with self-
    service? Requires business edition (v1.10.0+) with feature
    'useBackgroundServiceWithSelfServiceSourcesOnly' turned on. Defaults to
    false. Available in 0.10.4+.

.PARAMETER Priority
    Priority - The priority order of this source as compared to other
    sources, lower is better. Defaults to 0 (no priority). All priorities
    above 0 will be evaluated first, then zero-based values will be
    evaluated in config file order. Available in 0.9.9.9+.

.PARAMETER Credential
    Validate Credential used with authenticated feeds.

.PARAMETER KeyUser
    API Key User for the registered source.

.PARAMETER Key
    API Key for the registered source (used instead of credential when password length > 240 char).

.EXAMPLE
    Test-ChocolateySource -source https://chocolatey.org/api/v2 -priority 0

.NOTES
    https://github.com/chocolatey/choco/wiki/CommandsSource
#>
function Test-ChocolateySource {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '')]
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory
            ,ValueFromPipelineByPropertyName
        )]
        [System.String]
        $Name,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        $Source,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $Disabled,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $BypassProxy,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Switch]
        $SelfService,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [int]
        $Priority = 0,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [PSCredential]
        $Credential,

        #To be used when Password is too long (>240 char) like a key
        $KeyUser,
        $Key
    )

    Process {
        if (-not (Get-Command 'choco.exe' -CommandType Application -ErrorAction SilentlyContinue)) {
            Throw "Chocolatey Software not found."
        }

        if (-not ($Source = (Get-ChocolateySource -Name $Name)) ) {
            Write-Verbose "Chocolatey Source $Name cannot be found."
            Return $false
        }

        $ReferenceSource = [PSCustomObject]@{}
        foreach ( $Property in $PSBoundParameters.keys.where{
            $_ -notin ([System.Management.Automation.Cmdlet]::CommonParameters + [System.Management.Automation.Cmdlet]::OptionalCommonParameters)}
        )
        {
            if ($Property -notin @('Credential','Key','KeyUser')) {
                $MemberParams = @{
                    MemberType = 'NoteProperty'
                    Name = $Property
                    Value = $PSboundParameters[$Property]
                }
                $ReferenceSource | Add-Member @MemberParams
            }
            else {
                if ($Credential) {
                    $Username = $Credential.UserName
                }
                else {
                    $Username = $KeyUser
                }
                $PasswordParam = @{
                    MemberType = 'NoteProperty'
                    Name       = 'password'
                    Value      = 'Reference Object Password'
                }
                $UserNameParam = @{
                    MemberType = 'NoteProperty'
                    Name       = 'username'
                    Value      = $UserName
                }
                $ReferenceSource | Add-Member @PasswordParam -passthru | Add-Member @UserNameParam

                $securePasswordStr = $Source.Password
                $SecureStr = [System.Convert]::FromBase64String($SecurePasswordStr)
                $salt = [System.Text.Encoding]::UTF8.GetBytes("Chocolatey")
                $PasswordBytes = [Security.Cryptography.ProtectedData]::Unprotect($SecureStr, $salt, [Security.Cryptography.DataProtectionScope]::LocalMachine)
                $PasswordInFile = [system.text.encoding]::UTF8.GetString($PasswordBytes)

                if ($Credential) {
                    $PasswordParameter = $Credential.GetNetworkCredential().Password
                }
                else {
                    $PasswordParameter = $Key
                }

                if ($PasswordInFile -eq $PasswordParameter) {
                    Write-Verbose "The Passwords Match."
                    $Source.Password = 'Reference Object Password'
                }
                else {
                    Write-Verbose "The Password Do not Match."
                    $Source.Password = 'Source Object Password'
                }
            }
        }
        Compare-Object -ReferenceObject $ReferenceSource -DifferenceObject $Source -Property $ReferenceSource.PSObject.Properties.Name
    }
}
