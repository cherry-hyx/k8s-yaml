#!/bin/sh
port=9090
name=prometheus
dataDir=/data/prometheus/data
config=/data/prometheus/config/prometheus.yml
docker run -d -p ${port}:9090 --name ${name} --net="host" \
       -v ${config}:/etc/prometheus/prometheus.yml:ro \
       -v &{/data/prometheus/data}:/prometheus:rw \
        --restart=always \
       prom/prometheus --config.file=/etc/prometheus/prometheus.yml --web.enable-lifecycle

##如果需要更新prometheus配置
#curl -X POST http://localhost:9090/-/reload