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

# move the configuration files into the dir structure if they haven't already been placed
if [ ! -f "$GAMEBASE/dedicated_custom.yaml" ]; then
        cp /tmp/server/* "/home/user/Steam/steamapps/common/Empyrion - Dedicated Server"
fi

CLONEDIR="/home/user/Steam/steamapps/common/Empyrion - Dedicated Server/Content/Scenarios"
REPO_URL="https://https://github.com/DaStormBringer/empyrion-ReforgedEden.git"

# use [ touch update ] to create a file in the base game dir. If it exsists git will update the file
if [ -f "$GAMEBASE/update" ]; then
    cd "$CLONEDIR"  
    if [ ! -d "$CLONEDIR/.git" ]; then
      git init
      git remote add origin https://github.com/DaStormBringer/empyrion-ReforgedEden
      git fetch
    fi
    git checkout -f master
    rm -f "$GAMEBASE/update"
else
    echo "Update not Requested. Skipping clone."
fi

# if the Admin Config is in the base Directory move it to the correct dir
if [ -f "$GAMEBASE/adminconfig.yaml" ]; then
         mv "$GAMEBASE"/adminconfig.yaml "$GAMEBASE"/Saves
fi

mkdir -p "$GAMEDIR"/Logs

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
/opt/wine-staging/bin/wine ./EmpyrionDedicated.exe -batchmode -nographics -dedicated ../dedicated_custom.yaml -logFile Logs/current.log "$@" &> Logs/wine.log
