# Changelog for Chocolatey

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Modified project with new Sampler template.
- Invoking choco commands now always add `--no-progress` & `--limit-output`.
- Limiting Get-Command choco to the first result as per [#69](https://github.com/chocolatey-community/Chocolatey/issues/69) on all calls.
- Changed `ChocolateySoftware` to be class-based DSC Resource.
- Changed `ChocolateyPackage` to be class-based DSC Resource.
- Changed `ChocolateySource` to be a class-based DSC Resource.

### Added

- Added the `ChocolateyIsInstalled` Azure Automanage Machine Configuration package that validates that Chocolatey is installed.
- Added the `DisableChocolateyCommunitySource` Azure Automanage Machine Configuration package that ensures the Chocolatey Community source is disabled.
- Added repository's Wiki.

### Removed

- Removed SideBySide option as per [#61](https://github.com/chocolatey-community/Chocolatey/issues/61).
