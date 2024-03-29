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

GAMEBASE="$HOME/Steam/steamapps/common/Empyrion - Dedicated Server"
GAMEDIR="$HOME/Steam/steamapps/common/Empyrion - Dedicated Server/DedicatedServer"

cd "$HOME"
STEAMCMD="./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous +app_update 530870"

# add beta phase (must be set after app_update)
[ -z "$BETA" ] || STEAMCMD="$STEAMCMD -beta experimental"

# eval to support quotes in $STEAMCMD
eval "$STEAMCMD +quit"


CLONEDIR="/home/user/Steam/steamapps/common/Empyrion - Dedicated Server/Content"
UPDATEFILE="update"
REPO_URL="https://https://github.com/DaStormBringer/empyrion-ReforgedEden.git"
REPO_DIR="Scenarios"

# use [ touch update ] to create a file in the base game dir. If it exsists git will update the file
if [ -f "$GAMEBASE/$UPDATEFILE" ]; then
    cd "$CLONEDIR"  
    git clone "$REPO_URL" "$REPO_DIR"
    rm -f "$GAMEBASE/$UPDATEFILE"
else
    echo "Update not Requested. Skipping clone."
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

# We use dedicated_custom.yaml for server setup so that game updates does not overwrite the configuration
/opt/wine-staging/bin/wine ./EmpyrionDedicated.exe -batchmode -nographics -dedicated /dedicated_custom.yaml -logFile Logs/current.log "$@" &> Logs/wine.log
