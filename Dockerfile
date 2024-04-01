# syntax=docker/dockerfile:1
FROM ubuntu:jammy

LABEL maintainer="DaStormBringer"
LABEL org.opencontainers.image.description="Dedicated Empyrion Server for either Reforged Eden or Reforged Eden 2 Alpha"
LABEL org.opencontainers.image.source=https://github.com/DaStormBringer/empyrion-docker
LABEL version="0.2"

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
    ln -s '/home/user/Steam/steamapps/common/Empyrion - Dedicated Server/' /server && \
    useradd -m user
    
RUN export DEBIAN_FRONTEND noninteractive && apt-get update && apt-get install -y git 

RUN mkdir /tmp/server && chmod 1777 /tmp/server && mkdir -p "/home/user/Steam/steamapps/common/Empyrion - Dedicated Server"

COPY messages.py dedicated_custom.yaml adminconfig.yaml update /tmp/server/
RUN chown -Rv user:user "/home/user/Steam/steamapps/"

USER user
ENV HOME /home/user
WORKDIR /home/user

RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Get's killed at the end
RUN ./steamcmd.sh +login anonymous +quit || :

USER root

EXPOSE 30000/udp
EXPOSE 30001/udp
EXPOSE 30002/udp
EXPOSE 30003/udp
EXPOSE 30004/udp

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]
