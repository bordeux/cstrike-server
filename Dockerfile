FROM ubuntu:24.04

LABEL org.opencontainers.image.description="Counter Strike 1.6 server with amxmodx and usefull addons"
LABEL org.opencontainers.image.source=https://github.com/bordeux/cstrike-server

ENV SERVER_PORT=27015
ENV HLTV_PORT=27020
ENV HLTV_ENABLE=1
ENV HLTV_ARGS=""
ENV SERVER_MAP=de_dust2
ENV SERVER_LAN=0
ENV SERVER_MAX_PLAYERS=20
ENV SERVER_GAME=cstrike
ENV SERVER_PASSWORD="change-me"
ENV HLDS_ARGS=""
ENV ENABLE_HTTP_SERVER=1
ENV HTTP_SERVER_PORT=8080
ENV PROCESS_TEMPLATES=1
ENV AMXMODX_AUTOCOMPILE=1
ENV STEAM_PATH="/opt/steam"
ENV HLDS_PATH="${STEAM_PATH}/hlds"
ENV CSTRIKE_BASE_PATH="${HLDS_PATH}/cstrike_base"
ENV CSTRIKE_PATH="${HLDS_PATH}/cstrike"
ENV HELPERS_PATH="/usr/bin/helpers"

ARG BASE_PACK="https://github.com/bordeux/amxx-base-pack/archive/refs/heads/master.zip"
ARG GEOLITE_URL="https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-Country.mmdb"
ARG STEAMCMD_URL="media.steampowered.com/client/installer/steamcmd_linux.tar.gz"

# Installs the necessary dependencies for the SteamCMD installer.
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends libarchive-tools curl rsync file libc6:i386 lib32stdc++6 ca-certificates nginx gettext-base && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/nginx/sites-enabled/default && \
    service nginx stop 2>/dev/null || true

COPY --from=hairyhenderson/gomplate:stable /gomplate /bin/gomplate

# Creates a new user and group for the SteamCMD installer.
RUN groupadd -r steam && \
    useradd -r -g steam -m -d ${STEAM_PATH} steam

COPY ./start.sh /usr/bin
COPY ./entrypoint.sh /usr/bin
COPY ./entrypoint.sh.d /usr/bin/entrypoint.sh.d
COPY ./helpers ${HELPERS_PATH}
COPY ./nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /usr/bin/start.sh && \
    chmod +x /usr/bin/entrypoint.sh && \
    chmod +x /usr/bin/entrypoint.sh.d/*.sh && \
    chmod +x ${HELPERS_PATH}/*.sh

# Sets the user to the steam user.
USER steam
WORKDIR ${STEAM_PATH}

# Copies the hlds.txt file to the container.
COPY ./hlds.txt ${STEAM_PATH}

# Downloads and extracts the SteamCMD installer.
RUN curl -sL "${STEAMCMD_URL}" | tar xzvf - && \
    file ${STEAM_PATH}/linux32/steamcmd && \
    ./steamcmd.sh +runscript ${STEAM_PATH}/hlds.txt

RUN mkdir -p $HOME/.steam \
    && ln -s ${STEAM_PATH}/linux32 $HOME/.steam/sdk32 \
    && echo 70 > ${HLDS_PATH}/steam_appid.txt


RUN curl -L ${BASE_PACK} | bsdtar -xf - --strip-components=1 -C ${HLDS_PATH} && \
    chmod +x ${HLDS_PATH}/hlds_* && \
    curl -L -o ${CSTRIKE_PATH}/addons/amxmodx/data/GeoLite2-Country.mmdb ${GEOLITE_URL}

RUN echo "" >> ${CSTRIKE_PATH}/server.cfg && \
    echo "// Execute environment-based CVAR configuration" >> ${CSTRIKE_PATH}/server.cfg && \
    echo "exec custom.cfg" >> ${CSTRIKE_PATH}/server.cfg && \
    echo "exec env_cvar.cfg" >> ${CSTRIKE_PATH}/server.cfg && \
    touch ${CSTRIKE_PATH}/custom.cfg && \
    chmod +x ${CSTRIKE_PATH}/addons/amxmodx/scripting/amxxpc && \
    chmod +x ${HLDS_PATH}/hltv

RUN mv ${CSTRIKE_PATH} ${CSTRIKE_BASE_PATH}

WORKDIR ${HLDS_PATH}

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/usr/bin/start.sh"]