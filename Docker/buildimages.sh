#!/bin/sh


imageName="reg.aaa.io/api"
Version=$1

if [ -z "$Version" ] ;then
  Version=1.0
fi


function errOut {
  if [ $? -ne 0 ];then
    echo "$1"
    exit 1
  fi
}

function echoPre {
  echo "=============================="
}


function checkDocker {
  command -v docker >/dev/null 2>&1
  existsDocker=$?
  if [ $existsDocker -ne 0 ];then
     echoPre
    echo "未安装docker服务"
    yum install docker -y >/dev/null 2>&1 && systemctl start docker || errOut "安装docker出错！"
    echo "安装docker成功!"
     echoPre
  fi
}

function build {
  echoPre
  echo "build ttt-api"
  sh ./build.sh || errOut "构建ttt-api应用程序出错！"
  echo "build ttt-api succeed"
  echoPre
}

function buildImage  {
  echoPre
  docker build -t ${imageName}:${Version} -f ../docker/Dockerfile ../ || errOut "构建${imageName}:${Version}镜像错误！"
  echo "构建${imageName}:${Version}镜像成功！"
  echoPre
}


function pushImage {
  echoPre
  docker push ${imageName}:${Version}
  echoPre
}

function clearImage {
  echoPre
  docker rmi --force `docker images | grep "<none>"| awk '{print $3}'` &>/dev/null  && echo "删除无用镜像成功"
  echoPre
}

function main {
  checkDocker
  build
  buildImage
  pushImage
  clearImage
}

main
exit 0