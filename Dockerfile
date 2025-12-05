FROM ubuntu:24.04

ENV SERVER_PORT=27015
ENV SERVER_MAP=de_dust2
ENV SERVER_LAN=0
ENV SERVER_MAX_PLAYERS=20
ENV SERVER_GAME=cstrike
ENV SERVER_PASSWORD="change-me"
ENV STEAM_PATH="/opt/steam"
ENV HLDS_PATH="${STEAM_PATH}/hlds"

# Installs the necessary dependencies for the SteamCMD installer.
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends libarchive-tools curl rsync file libc6:i386 lib32stdc++6 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Creates a new user and group for the SteamCMD installer.
RUN groupadd -r steam && \
    useradd -r -g steam -m -d ${STEAM_PATH} steam

COPY ./start.sh /usr/bin
COPY ./entrypoint.sh /usr/bin

RUN chmod +x /usr/bin/start.sh && chmod +x /usr/bin/entrypoint.sh

# Sets the user to the steam user.
USER steam
WORKDIR ${STEAM_PATH}

# Copies the hlds.txt file to the container.
COPY ./hlds.txt ${STEAM_PATH}

# Downloads and extracts the SteamCMD installer.
RUN curl -v -sL media.steampowered.com/client/installer/steamcmd_linux.tar.gz | tar xzvf - && \
    file /opt/steam/linux32/steamcmd && \
    ./steamcmd.sh +runscript ${STEAM_PATH}/hlds.txt

RUN mkdir -p $HOME/.steam \
    && ln -s ${STEAM_PATH}/linux32 $HOME/.steam/sdk32 \
    && echo 70 > ${HLDS_PATH}/steam_appid.txt

RUN curl -L "https://github.com/AMXX-pl/BasePack/releases/download/1.2.0/base_pack.zip" | bsdtar -xf - -C ${HLDS_PATH} && \
    chmod +x ${HLDS_PATH}/hlds_* && \
    mv ${HLDS_PATH}/cstrike ${HLDS_PATH}/cstrike_base

WORKDIR ${HLDS_PATH}

ENTRYPOINT ["/usr/bin/entrypoint.sh"]