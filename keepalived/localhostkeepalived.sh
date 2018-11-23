#!/bin/sh
# by hjb
# 2018.10.27 22.38
#localhost
#VIP地址:10.66.3.203
#如果是K8S节点,最好先执行kubectl drain node5  --ignore-daemonsets --force
if [ -z "$1" ];then
    echo "\$1 not null"
    exit 1
fi
node=$1
netdev="ens32"
vip="1111"

routeNum=55

###需要写入非本机的MAC地址,即另一个节点的mac,所以使用
node1_ip="1111"
node1_write_mac="00:50:56:93:80:3d"

node2_ip="1111"
node2_write_mac="00:50:56:93:49:c9"


t_ip="${node}_ip"
t_mac="${node}_write_mac"
eval ip="$"${t_ip}
eval mac="$"${t_mac}
echo ip:$ip

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




cat >> /etc/sysctl.conf <<EOF
net.ipv4.conf.${netdev}.arp_ignore = 1 
net.ipv4.conf.${netdev}.arp_announce = 2 
net.ipv4.ip_forward = 1
EOF
sysctl -p


iptables  -t mangle -I PREROUTING -d ${vip} -p tcp -m tcp --dport 80 -m mac ! --mac-source ${mac} -j MARK --set-mark 0x${fwmark80}
iptables  -t mangle -I PREROUTING -d ${vip} -p tcp -m tcp --dport 443 -m mac ! --mac-source ${mac} -j MARK --set-mark 0x${fwmark443}
cat >> /etc/rc.local <<EOF
/usr/sbin/ip addr add ${vip}/32 dev lo:0 broadcast ${vip}
iptables  -t mangle -I PREROUTING -d ${vip} -p tcp -m tcp --dport 80 -m mac ! --mac-source ${mac} -j MARK --set-mark 0x${fwmark80}
iptables  -t mangle -I PREROUTING -d ${vip} -p tcp -m tcp --dport 443 -m mac ! --mac-source ${mac} -j MARK --set-mark 0x${fwmark443}
swapoff -a
EOF

iptables -vL -t mangle

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

virtual_server fwmark ${fwmark80} { 
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

virtual_server fwmark ${fwmark443} { 
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
systemctl stop keepalived
systemctl start keepalived
