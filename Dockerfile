# syntax=docker/dockerfile:1
FROM ubuntu:jammy

LABEL maintainer="DaStormBringer"
LABEL org.opencontainers.image.description="Dedicated Empyrion Server for either Reforged Eden or Reforged Eden 2 Alpha"
LABEL org.opencontainers.image.source=https://github.com/DaStormBringer/empyrion-docker
LABEL version="0.3"

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN export DEBIAN_FRONTEND noninteractive && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y net-tools tar unzip curl xz-utils gnupg2 software-properties-common xvfb libc6:i386 locales && \
    echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && locale-gen && \
    curl -s https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    apt-add-repository -y 'deb https://dl.winehq.org/wine-builds/ubuntu/ jammy main' && \
    apt-get install -y wine-staging wine-staging-i386 wine-staging-amd64 winetricks && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    ln -s '/home/user/Steam/steamapps/common/Empyrion - Dedicated Server/' /server && \
    useradd -m user

COPY entrypoint.sh /

RUN export DEBIAN_FRONTEND noninteractive && apt-get update && apt-get install -y git && \
    mkdir /tmp/server && chmod 1777 /tmp/server && mkdir -p "/home/user/Steam/steamapps/common/Empyrion - Dedicated Server" && \
    chmod +x /entrypoint.sh && chown -Rv user:user "/home/user/Steam/steamapps/"

COPY messages.py dedicated_custom.yaml adminconfig.yaml update /tmp/server/
		
EXPOSE 30000/udp
EXPOSE 30001/udp

USER user
ENV HOME /home/user
WORKDIR /home/user

RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - && \
   ./steamcmd.sh +login anonymous +quit || :

ENTRYPOINT ["/entrypoint.sh"]
