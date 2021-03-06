#!/bin/sh
# by hjb
# 2018.10.27 22.38
#  ds 服务器
#VIP地址:10.66.3.203
#如果是K8S节点,最好先执行kubectl drain node5  --ignore-daemonsets --force
if [ -z "$1" ];then
    echo "\$1 not null"
    exit 1
fi
node=$1
netdev="ens32"
vip="11111"

routeNum=87

###需要写入非本机的MAC地址,即另一个节点的mac,所以使用n
node1_ip="1111"
node2_ip="1111"


if [ "${node}" == "node1" ]
then
    role="MASTER"
    priority=110
    fwmark80='3'
    fwmark443='5'
else
    role="BACKUP"
    priority=100
    fwmark80='4'
    fwmark443='6'
fi

cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_instance VI_1 {
    state ${role} #BACKUP 为slave MASTER
    interface ${netdev}
    virtual_router_id  ${routeNum} #路由通道
    priority ${priority}
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 111111
    }
    virtual_ipaddress {
       ${vip}
    }
}

virtual_server $vip 80 { 
    delay_loop 3 # 设置健康检查时间，单位是秒
    lb_algo wrr # 设置负载调度的算法为wlc,wrr
    lb_kind DR # 设置LVS实现负载的机制，有DR、TUN、DR三个模式
    persistence_timeout 0
    protocol TCP
    real_server ${node1_ip} 80 {
        weight 3
        TCP_CHECK {
            connect_timeout 3
            retry 3
            delay_before_retry 3
            connect_port 80
        }
    }
    real_server ${node2_ip} 80 {
        weight 3
        TCP_CHECK {
            connect_timeout 3
            retry 3
            delay_before_retry 3
            connect_port 80
        }
    }
}

virtual_server $vip 443 { 
    delay_loop 3 # 设置健康检查时间，单位是秒
    lb_algo wrr # 设置负载调度的算法为wlc,wrr
    lb_kind DR # 设置LVS实现负载的机制，有DR、TUN、DR三个模式
    persistence_timeout 0
    protocol TCP
    real_server ${node1_ip} 443 {
        weight 3
        TCP_CHECK {
            connect_timeout 3
            retry 3
            delay_before_retry 3
            connect_port 443
        }
    }
    real_server ${node2_ip} 443 {
        weight 3
        TCP_CHECK {
            connect_timeout 3
            retry 3
            delay_before_retry 3
            connect_port 443
        }
    }
}
EOF
