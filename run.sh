#!/bin/bash

# 容器名称
IMAGE_NAME="docker.wodedata.com/videolingo:latest"
CONTAINER_NAME="videolingo"

# 获取当前脚本的全路径
SCRIPT_PATH=$(dirname "$(realpath "$0")")
echo "==== run.sh SCRIPT_PATH: $SCRIPT_PATH"
# 如果 realpath 不可用，可以使用 readlink
# SCRIPT_PATH="$(readlink -f $0)"

# start container
function start_container() {
    # 检查容器是否存在
    if [[ "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]]; then
        # 容器存在
        docker start ${CONTAINER_NAME}
    else
	    docker volume inspect n8n_data >/dev/null 2>&1 || docker volume create \
	        --opt type=none \
	        --opt device=/opt/docker/n8n/data \
	        --opt o=bind \
	        n8n_data

        # 容器不存在，创建并运行
        DIR="$(dirname $(realpath $0))"
        echo "Creating and running container ${CONTAINER_NAME}..."
        docker run -dit \
            --name=${CONTAINER_NAME} \
            --restart=unless-stopped \
            -p 8501:8501 \
            --gpus all  \
            ${IMAGE_NAME}
        #
    fi

}


# 检查传入参数
ACTION=$1

case $ACTION in
    stop)
        echo "Stopping container ${CONTAINER_NAME}..."
        docker stop ${CONTAINER_NAME}
        ;;
    restart)
        echo "Restarting container ${CONTAINER_NAME}..."
        docker restart ${CONTAINER_NAME}
        ;;
    rm)
        echo "Removing container ${CONTAINER_NAME}..."
        docker rm -f ${CONTAINER_NAME}
        ;;
    *)
        echo "Starting container ${CONTAINER_NAME} ..."
        start_container
        ;;
esac


