# palworld-server-start-script
## 一键启动帕鲁服！
* Linux \
```
wget https://github.com/guestc/palworld-server-start-script/blob/main/linux/startPalworldInDocker.sh \
wget https://github.com/guestc/palworld-server-start-script/blob/main/linux/env.list \
chmod +x startPalworldInDocker.sh
```
如果下载失败，尝试下面的
```
wget https://mirror.ghproxy.com/https://github.com/guestc/palworld-server-start-script/blob/main/linux/startPalworldInDocker.sh \
wget https://mirror.ghproxy.com/https://github.com/guestc/palworld-server-start-script/blob/main/linux/env.list \
chmod +x startPalworldInDocker.sh
```

下载完后，修改env.list里面服务器设置后直接启动
```
./startPalworldInDocker.sh
```

* Windows \
'''
curl -o startPalword.bat https://mirror.ghproxy.com/https://raw.githubusercontent.com/guestc/palworld-server-start-script/main/windwos/startPalword.bat
startPalword.bat
'''
* 引用 
docker 镜像修改来自：https://github.com/jammsen/docker-palworld-dedicated-server
服务器配置文件 参考：https://github.com/knva/PalWorld_server_config
