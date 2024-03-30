FROM ubuntu:jammy

LABEL maintainer="DaStormBringer"
LABEL version="0.1"
LABEL description="Dedicated Empyrion Server for either Reforged Eden or Reforged Eden 2 Alpha"

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

USER user
ENV HOME /home/user
WORKDIR /home/user

RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Get's killed at the end
RUN ./steamcmd.sh +login anonymous +quit || :

WORKDIR "Steam/steamapps/common/Empyrion - Dedicated Server"

USER root
RUN mkdir /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

EXPOSE 30000/udp
EXPOSE 30001/udp
EXPOSE 30002/udp
EXPOSE 30003/udp
EXPOSE 30004/udp

RUN chown -R user:user "/home/user/Steam/steamapps/common/Empyrion - Dedicated Server"

COPY messages.py .
COPY dedicated_custom.yaml .
COPY adminconfig.yaml .
COPY update .
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

VOLUME /home/user/Steam

ENTRYPOINT ["/entrypoint.sh"]
