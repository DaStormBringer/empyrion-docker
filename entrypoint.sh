#!/bin/bash -ex

##Empyrion AppID 383120
##RE 1.10 2918811239
[ "$UID" != 0 ] || {
    mkdir -p ~user/Steam
    chown user: ~user/Steam
    runuser -u user "$0" "$@"
    exit 0
}

GAMEDIR="$HOME/Steam/steamapps/common/Empyrion - Dedicated Server/DedicatedServer"

cd "$HOME"
STEAMCMD="./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous $STEAMCMD"
[ -z "$BETA" ] || STEAMCMD="$STEAMCMD -beta experimental"

# eval to support quotes in $STEAMCMD
eval "$STEAMCMD +app_update 530870 +quit"
eval "$STEAMCMD workshop_download_item 383120 2550354956"

mkdir -p "$GAMEDIR/Logs"

rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 800x600x24 &
export WINEDLLOVERRIDES="mscoree,mshtml="
export DISPLAY=:1

cd "$GAMEDIR"

[ "$1" = "bash" ] && exec "$@"

sh -c 'until [ "`netstat -ntl | tail -n+3`" ]; do sleep 1; done
sleep 5 # gotta wait for it to open a logfile
tail -F Logs/current.log ../Logs/*/*.log 2>/dev/null' &
exec bash
#/opt/wine-staging/bin/wine ./EmpyrionDedicated.exe -batchmode -nographics -logFile Logs/current.log "$@" &> Logs/wine.log
