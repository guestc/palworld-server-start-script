#!/bin/bash
DOCKER_IAMGE=registry.cn-guangzhou.aliyuncs.com/guestc/palworld-dedicated-server:v1.3
CONTAINER_NAME=palworld
GAME_PORT=8211
RCON_PORT=25575
GAME_PATH=$(pwd)/ServerData

if [ ! -d "$GAME_PATH" ]; then
	mkdir $GAME_PATH
fi

echo "服务器安装路径：$GAME_PATH"
chmod 777 $GAME_PATH

installDocker(){
	if command -v docker &> /dev/null; then
		docker_version=$(docker --version)
		echo "Docker 已安装，版本为: $docker_version"
	else
		echo "Docker 未安装"
		curl -sSL https://get.docker.com/ | CHANNEL=stable bash -s docker --mirror Aliyun
		sudo systemctl enable --now docker
	fi
}
readGamePort(){
	ENV_LIST=$(cat ./env.list)
	GAME_PORT=$(echo "$ENV_LIST" | grep -oP 'SERVER_PORT=\K\d+')
	echo "读取游戏端口为：$GAME_PORT"
}
readRconPort(){
	ENV_LIST=$(cat ./env.list)
	RCON_PORT=$(echo "$ENV_LIST" | grep -oP 'RCON_PORT=\K\d+')
	echo "读取RCON端口为：$RCON_PORT"
}


initContainer(){
	docker run --name $CONTAINER_NAME --env-file ./env.list -v $GAME_PATH:/home/container -it -p $GAME_PORT:$GAME_PORT/udp -p $RCON_PORT:$RCON_PORT/tcp $DOCKER_IAMGE
}


installDocker
readGamePort

if docker ps -a --format "{{.Names}}" | grep -q "$CONTAINER_NAME"; then
  echo "容器 $CONTAINER_NAME 存在"
  docker stop $CONTAINER_NAME
  docker rm $CONTAINER_NAME
fi
initContainer
