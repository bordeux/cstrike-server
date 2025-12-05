FROM ubuntu:24.04


# Sets an environment variable for the image name.
ARG IMAGE=custom
ENV IMAGE ${IMAGE}

# Installs the necessary dependencies for the SteamCMD installer.
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl rsync file libc6:i386 lib32stdc++6 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Creates a new user and group for the SteamCMD installer.
RUN groupadd -r steam && \
    useradd -r -g steam -m -d /opt/steam steam

# Creates the necessary directories for the Half-Life Dedicated Server, including the configuration and mods directories.
RUN mkdir /config
RUN mkdir /mods
RUN mkdir /temp
RUN mkdir /temp/config
RUN mkdir /temp/mods

# Sets the user to the steam user.
USER steam
WORKDIR /opt/steam

# Copies the hlds.txt file to the container.
COPY ./hlds.txt /opt/steam

# Downloads and extracts the SteamCMD installer.
RUN curl -v -sL media.steampowered.com/client/installer/steamcmd_linux.tar.gz | tar xzvf - && \
    file /opt/steam/linux32/steamcmd && \
    ./steamcmd.sh +runscript /opt/steam/hlds.txt

# Writes the steam_appid.txt file to the hlds directory with the title id for Half-Life.
# Patches a known issue with the Steam client.
RUN mkdir -p $HOME/.steam \
    && ln -s /opt/steam/linux32 $HOME/.steam/sdk32 \
    && echo 70 > /opt/steam/hlds/steam_appid.txt

WORKDIR /opt/steam/hlds

ENTRYPOINT ["/opt/steam/hlds/hlds_run"]