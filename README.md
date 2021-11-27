[![Build Status](https://ci.k8s.clowa.de/api/badges/clowa/docker-powershell-core/status.svg)](https://ci.k8s.clowa.de/clowa/docker-terraform)

# Overview

Docker image with corresponding powershell core version.

Supported platforms:

- linux/amd64
- linux/arm64/v8

# CI setups for Drone

Fire this command to setup the cron schedule.

```bash
drone cron add "clowa/docker-powershell-core" "nightly" "0 0 1 * * *"
```
