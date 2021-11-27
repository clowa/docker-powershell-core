[![Build Status](https://ci.k8s.clowa.de/api/badges/clowa/docker-powershell-core/status.svg)](https://ci.k8s.clowa.de/clowa/docker-powershell-core)

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

# CI setups for Drone

Fire this command to setup the cron schedule.

```bash
drone cron add "clowa/docker-powershell-core" "nightly" "0 0 1 * * *"
```
