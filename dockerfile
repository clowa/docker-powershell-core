# This Dockerfile builds a cross platform docker image of powershell.
# It uses the GitHub releases of powershell core to install powershell
# from tarball.

FROM --platform=$BUILDPLATFORM ubuntu:20.04 as build

ARG POWERSHELL_VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TZ Europe/Berlin
ARG DEBIAN_FRONTEND noninteractive

# What's going on here?
# - Install curl to download tarball
# - Translate architecture to match powershell architecture
# - Download the powershell '.tar.gz' archive

RUN DEBIAN_FRONTEND=${DEBIAN_FRONTEND}; \
    TZ=${TZ}; \
    apt-get update -qq && \
    apt-get install -qq --yes curl && \
    apt-get clean -qq --yes && \
    rm -rf /var/lib/apt/lists/* && \
    case ${TARGETARCH} in \
         "amd64") PWSH_ARCH=x64           ;; \
         "arm")   PWSH_ARCH=arm32         ;; \
         *)       PWSH_ARCH=${TARGETARCH} ;; \
    esac && \
    curl --silent --location --output /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-${TARGETOS}-${PWSH_ARCH}.tar.gz

# Create the target folder where powershell will be placed and expand powershell to the target folder
RUN mkdir -p /opt/microsoft/powershell/7 && \
    tar -zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7

###########
## Final ##
###########
FROM ubuntu:20.04 as final

ARG TZ Europe/Berlin
ARG DEBIAN_FRONTEND noninteractive

#LABEL maintainer="My Company Team <email@example.org>"

# Upgrade packages and cleanup unused dependencies
RUN DEBIAN_FRONTEND=${DEBIAN_FRONTEND}; \
    TZ=${TZ}; \
    apt-get update -qq && \ 
    apt-get full-upgrade -qq --yes && \
    apt-get dist-upgrade -qq --yes && \
    apt-get autoremove -qq --yes && \
    apt-get clean -qq --yes && \
    rm -rf /var/lib/apt/lists/*


RUN DEBIAN_FRONTEND=${DEBIAN_FRONTEND}; \
    TZ=${TZ}; \
    apt-get update -qq && \
    apt-get install -qq --yes locales && \
    apt-get clean -qq --yes && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
    
ENV \
    # Define ENVs for Localization/Globalization
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    # Set a fixed location for the Module analysis cache.
    # See: https://github.com/PowerShell/PowerShell-Docker/issues/103
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache

# Install additional CA certs.
RUN DEBIAN_FRONTEND=${DEBIAN_FRONTEND}; \
    TZ=${TZ}; \
    apt-get update -qq && \
    apt-get install -qq --yes ca-certificates && \
    apt-get clean -qq --yes && \
    rm -rf /var/lib/apt/lists/*

# Install the requirements of powershell / .NET
RUN DEBIAN_FRONTEND=${DEBIAN_FRONTEND}; \
    TZ=${TZ}; \
    apt-get update -qq && \
    apt-get install -qq --yes --no-install-recommends \
        less \
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu66 \
        libssl1.1 \
        libstdc++6 \
        zlib1g \
        libgdiplus && \
    apt-get clean -qq --yes && \
    rm -rf /var/lib/apt/lists/*

# Copy only the files we need from the previous stage
COPY --from=build ["/opt/microsoft/powershell", "/opt/microsoft/powershell"]

# Give all user execute permissions and remove write permissions for others
RUN chmod a+x,o-w /opt/microsoft/powershell/7/pwsh && \
    # Create the pwsh symbolic link that points to powershell
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Set default shell of RUN command to powershell
SHELL ["pwsh", "-command"]

CMD ["/usr/bin/pwsh"]