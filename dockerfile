# This Dockerfile builds a cross platform docker image of powershell.
# It uses the GitHub releases of powershell core to install powershell
# from tarball.

ARG PWSH_INSTALL_VERSION

################
## Downloader ##
################
FROM --platform=$BUILDPLATFORM ubuntu:22.04 as downloader

ARG PWSH_VERSION
ARG TARGETOS
ARG TARGETARCH

ENV TZ=Europe/Berlin
ENV DEBIAN_FRONTEND=noninteractive

# What's going on here?
# - Install curl to download tarball
# - Translate architecture to match powershell architecture
# - Download the powershell '.tar.gz' archive

RUN apt-get update -qq && \
    apt-get install -qq --yes curl && \
    apt-get clean -qq --yes && \
    rm -rf /var/lib/apt/lists/* && \
    case ${TARGETARCH} in \
         "amd64") PWSH_ARCH=x64           ;; \
         "arm")   PWSH_ARCH=arm32         ;; \
         *)       PWSH_ARCH=${TARGETARCH} ;; \
    esac && \
    curl --silent --location --output /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-${TARGETOS}-${PWSH_ARCH}.tar.gz

# define the folder we will be installing PowerShell to
ENV POWERSHELL_INSTALL_FOLDER=/opt/microsoft/powershell/${PWSH_INSTALL_VERSION}

# Create the target folder where powershell will be placed and expand powershell to the target folder
RUN mkdir -p ${POWERSHELL_INSTALL_FOLDER} && \
    tar -zxf /tmp/powershell.tar.gz -C ${POWERSHELL_INSTALL_FOLDER}

###########
## Final ##
###########
FROM ubuntu:22.04 as final

ENV TZ=Europe/Berlin
ENV DEBIAN_FRONTEND=noninteractive

LABEL maintainer="Cedric Ahlers <service.clowa@gmail.com>"

# Upgrade packages and cleanup unused dependencies 
RUN apt-get update -qq && \ 
    apt-get full-upgrade -qq --yes && \
    apt-get dist-upgrade -qq --yes && \
    apt-get autoremove -qq --yes && \
    apt-get clean -qq --yes && \
    rm -rf /var/lib/apt/lists/*

ENV \
    # Define ENVs for Localization/Globalization
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    # Set a fixed location for the Module analysis cache.
    # See: https://github.com/PowerShell/PowerShell-Docker/issues/103
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache

# Set locale to en_US.UTF-8
RUN apt-get update -qq && \
    apt-get install -qq --yes locales && \
    apt-get clean -qq --yes && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen ${LANG} && update-locale

# Install additional CA certs.
RUN apt-get update -qq && \
    apt-get install -qq --yes ca-certificates && \
    apt-get clean -qq --yes && \
    rm -rf /var/lib/apt/lists/*

# Install the requirements of powershell / .NET
RUN apt-get update -qq && \
    apt-get install -qq --yes --no-install-recommends \
    # less is required for help in powershell
        less \
    # required for SSL
        ca-certificates \
        gss-ntlmssp \
        libc6 \
        libgcc1 \
        libgcc-s1 \
        libgssapi-krb5-2 \
        libicu70 \
        liblttng-ust1 \
        libssl3 \
        libstdc++6 \
        libunwind8 \
        zlib1g \
    # PowerShell remoting over SSH dependencies
        openssh-client \
    # Required by dotnet apps using System.Drawing.Common assembly
        libgdiplus && \
    # Cleanup stuff
    apt-get clean -qq --yes && \
    rm -rf /var/lib/apt/lists/*

# Copy only the files we need from the previous stage
COPY --from=downloader ["/opt/microsoft/powershell", "/opt/microsoft/powershell"]

# Give all user execute permissions and remove write permissions for others
RUN chmod a+x,o-w /opt/microsoft/powershell/${PWSH_INSTALL_VERSION}/pwsh && \
    # Create the pwsh symbolic link that points to powershell
    ln -s /opt/microsoft/powershell/${PWSH_INSTALL_VERSION}/pwsh /usr/bin/pwsh && \
    # Intialize powershell module cache
    # and disable telemetry
    export POWERSHELL_TELEMETRY_OPTOUT=1; \
    pwsh \
        -NoLogo \
        -NoProfile \
        -Command " \
          \$ErrorActionPreference = 'Stop' ; \
          \$ProgressPreference = 'SilentlyContinue' ; \
          while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) {  \
            Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
            Start-Sleep -Seconds 6 ; \
          }"

# Set default shell of RUN command to powershell
SHELL ["pwsh", "-command"]

CMD ["pwsh"]