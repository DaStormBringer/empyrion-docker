# empyrion-server
**Docker image for the [Empyrion](https://empyriongame.com/) dedicated server with [Reforged Eden](https://steamcommunity.com/sharedfiles/filedetails/?id=2550354956) using WINE**

The image itself contains WINE and steamcmd, along with an entrypoint.sh script that bootstraps the Empyrion dedicated server install via steamcmd.

When running the image, it will mount the volume /home/user/Steam, to persist the Empyrion install and avoid downloading it on each container start.
The configuration files will be under `gamedir/steamapps/common/Empyrion - Dedicated Server`

Starting Commands:
```
cd empyrion-docker
docker build -t empyrion-dedicated-server .
mkdir -p gamedir
docker run -di --name emp -p 30000:30000/udp -p 30001:30001/udp --restart unless-stopped -v $PWD/gamedir:/home/user/Steam empyrion-dedicated-server
```
```
# for experimental version:
cd empyrion-docker
docker build -t empyrion-dedicated-server .
mkdir -p gamedir_beta
docker run -di --name emp -p 30000:30000/udp -p 30001:30001/udp --restart unless-stopped -v $PWD/gamedir_beta:/home/user/Steam -e BETA=1 empyrion-dedicated-server
```

After first run you can use:
```
docker start emp
```
```
docker stop emp
```
to control the server

You can use 
```
docker logs -f emp
``` 
to view the logs and progression of the server

The server will take a LONG time to start on the first run. It has to download steam and the Reforged Eden files. (expect 15-30 minutes)

If you want to update Reforged Eden then use  `touch update` in the `gamedir/steamapps/common/Empyrion - Dedicated Server` and restart the server.
This will cause it to do a git update and pull any updated files.

After starting the server, you can edit the dedicated_custom.yaml file at 'gamedir/steamapps/common/Empyrion - Dedicated Server/dedicated_custom.yaml'.
You'll need to restart the docker container after editing.

If you want to pick Reforged Eden 1 and not Reforged Eden 2 then edit the `dedicated_custom.yaml` before your first start and uncomment the Reforged Eden 1 section and comment out the Reforged Eden 2 section

```
# Pick one and uncomment/comment the other  
GameConfig:
  GameName: Reforged Eden 2
  Mode: Survival
  Seed: 1011345
  CustomScenario: Reforged Eden 2
  
#GameConfig:
#  GameName: Reforged Eden
#  Mode: Survival
#  Seed: 1011345
#  CustomScenario: Reforged Eden
```

The DedicatedServer folder has been symlinked to /server, so that you can refer to saves with z:/server/Saves (for instance the save called The\_Game):
```
# cp -r /..../Saves/Games/The_Game 'gamedir/steamapps/common/Empyrion - Dedicated Server/Saves/Games/'
# you might want a symlink for games: ln -s 'gamedir/steamapps/common/Empyrion - Dedicated Server/Saves/Games'
docker run -di --name emp -p 30000:30000/udp -p 30001:30001/udp --restart unless-stopped -v $PWD/gamedir:/home/user/Steam bitr/empyrion-server -dedicated 'z:/server/Saves/Games/The_Game/dedicated.yaml'
```

To append arguments to the steamcmd command, use `-e "STEAMCMD=..."`. Example: `-e "STEAMCMD=+runscript /home/user/Steam/addmods.txt"`.

For more information about the dedicated server itself, refer to the [wiki](https://empyrion.fandom.com/wiki/Guide/Setting_Up_Dedicated_Server).
