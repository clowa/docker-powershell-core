![Get latest release version](https://github.com/clowa/docker-powershell-core/actions/workflows/get-latest-release.yml/badge.svg)
![Build docker images](https://github.com/clowa/docker-powershell-core/actions/workflows/docker-buildx.yml/badge.svg)

# Overview

Docker image with corresponding powershell core version.

Supported platforms:

- `linux/amd64`
- `linux/arm64/v8`
- `linux/arm/v7`

# Sources

- [Installation instructions](https://docs.microsoft.com/de-de/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.2#installation---binary-archives)
- [Dependencies](https://docs.microsoft.com/de-de/dotnet/core/install/linux-ubuntu#dependencies)
- [Powershell Core repository](https://github.com/PowerShell/PowerShell)

# CI setups

1. checks every day if a new release is available at the [powershell repository](https://github.com/powershell/powershell)
2. Build new docker images with the new release.
