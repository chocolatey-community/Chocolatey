[cmdletBinding()]
Param (
    [Parameter(Position=0)]
    $Tasks,

    [switch]
    $ResolveDependency,

    [System.String]
    $BuildOutput = "BuildOutput",

    $ModuleVersion = $(if($Env:APPVEYOR_BUILD_VERSION) {$ENV:APPVEYOR_BUILD_VERSION} else { try { Get-NextNugetPackageVersion -Name 'Chocolatey' -EA Stop} catch { '0.0.1' }} ),

    [String[]]
    $GalleryRepository,

    [Uri]
    $GalleryProxy,

    [Switch]
    $ForceEnvironmentVariables = [switch]$true,

    $MergeList = @('enum*',[PSCustomObject]@{Name='class*';order={(Import-PowerShellDataFile .\SampleModule\Classes\classes.psd1).order.indexOf($_.BaseName)}},'priv*','pub*')

    ,$CodeCoverageThreshold = 6
)

Process {
    if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
        Invoke-Build $Tasks $MyInvocation.MyCommand.Path @PSBoundParameters
        return
    }
    Write-Warning $ModuleVersion
    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $PSScriptRoot -ChildPath $BuildOutput
    }

    if (($Env:PSModulePath -split ';') -notcontains (Join-Path $BuildOutput 'modules') ) {
        $Env:PSModulePath += ';' + (Join-Path $BuildOutput 'modules')
    }

    Get-ChildItem -Path "$PSScriptRoot/.build/" -Recurse -Include *.ps1 -Verbose |
        Foreach-Object {
            "Importing file $($_.BaseName)" | Write-Verbose
            . $_.FullName
        }

    task none {}
     task .  Clean,
            SetBuildEnvironment,
            QualityTestsStopOnFail,
            CopySourceToModuleOut,
            MergeFilesToPSM1,
            CleanOutputEmptyFolders,
            UpdateModuleManifest,
            UnitTests,
            UploadUnitTestResultsToAppVeyor,
            FailBuildIfFailedUnitTest,
            FailIfLastCodeConverageUnderThreshold,
            IntegrationTests,
            DeployAll

    task testAll UnitTests, IntegrationTests, QualityTestsStopOnFail
}

begin {
    Push-Location $PSScriptRoot
    function Resolve-Dependency {
        [CmdletBinding()]
        param()

        if (!(Get-PackageProvider -Name NuGet -ForceBootstrap)) {
            $providerBootstrapParams = @{
                Name = 'nuget'
                force = $true
                ForceBootstrap = $true
            }
            if ($PSBoundParameters.ContainsKey('verbose')) { $providerBootstrapParams.add('verbose',$verbose)}
            if ($GalleryProxy) { $providerBootstrapParams.Add('Proxy',$GalleryProxy) }
            $null = Install-PackageProvider @providerBootstrapParams
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }

        if (!(Get-Module -Listavailable PSDepend)) {
            Write-verbose "BootStrapping PSDepend"
            "Parameter $BuildOutput"| Write-verbose
            $InstallPSDependParams = @{
                Name = 'PSDepend'
                AllowClobber = $true
                Confirm = $false
                Force = $true
                Scope = 'CurrentUser'
            }
            if ($PSBoundParameters.ContainsKey('verbose')) { $InstallPSDependParams.add('verbose',$verbose)}
            if ($GalleryRepository) { $InstallPSDependParams.Add('Repository',$GalleryRepository) }
            if ($GalleryProxy)      { $InstallPSDependParams.Add('Proxy',$GalleryProxy) }
            if ($GalleryCredential) { $InstallPSDependParams.Add('ProxyCredential',$GalleryCredential) }
            Install-Module @InstallPSDependParams
        }

        $PSDependParams = @{
            Force = $true
            Path  = "$PSScriptRoot\Dependencies.psd1"
        }
        if ($PSBoundParameters.ContainsKey('verbose')) { $PSDependParams.add('verbose',$verbose)}
        Invoke-PSDepend @PSDependParams
        Write-Verbose "Project Bootstrapped, returning to Invoke-Build"
    }

    if ($ResolveDependency) {
        Resolve-Dependency
    }
}
