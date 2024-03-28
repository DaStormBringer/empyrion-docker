#!/bin/bash -ex
#Notes: steamcmd +login anonymous +force_install_dir c:\Empyrion +app_update 530870 validate +quit
##Empyrion AppID 383120
##Empyrion Dedicated Server AppID 530870
##RE 1.11 2918811239
##RE 2 (Alpha) 3143225812
[ "$UID" != 0 ] || {
    mkdir -p ~user/Steam
    chown user: ~user/Steam
    runuser -u user "$0" "$@"
    exit 0
}

GAMEDIR="$HOME/Steam/steamapps/common/Empyrion - Dedicated Server/DedicatedServer"

cd "$HOME"
STEAMCMD="./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous $STEAMCMD +app_update 530870"

# add beta phase (must be set after app_update)
[ -z "$BETA" ] || STEAMCMD="$STEAMCMD -beta experimental"

# eval to support quotes in $STEAMCMD
eval "$STEAMCMD +quit"

SCENARIOS_DIR="/home/user/Steam/steamapps/common/Empyrion - Dedicated Server/Content/Scenarios"
RE_DIR="ReforgedEden2"

# Check if the repository directory already exists
if [ ! -d "$SCENARIOS_DIR/$REPO_DIR" ]; then
    cd "$SCENARIOS_DIR"
   #  SOmething something maybe download and unzip
else
    echo "Scenarios directory '$RE_DIR' already exists. Skipping clone."
fi


mkdir -p "$GAMEDIR/Logs"

rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 800x600x24 -nolisten unix &
export WINEDLLOVERRIDES="mscoree,mshtml="
export DISPLAY=:1

cd "$GAMEDIR"

[ "$1" = "bash" ] && exec "$@"

sh -c 'until [ "`netstat -ntl | tail -n+3`" ]; do sleep 1; done
sleep 5 # gotta wait for it to open a logfile
tail -F Logs/current.log ../Logs/*/*.log 2>/dev/null' &

/opt/wine-staging/bin/wine ./EmpyrionDedicated.exe -batchmode -nographics -dedicated /dedicated_custom.yaml -logFile Logs/current.log "$@" &> Logs/wine.log
