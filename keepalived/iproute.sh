#!/bin/sh
SNS_VIP=111
case "$1" in
start)
       ip addr add $SNS_VIP/32 dev lo:0 broadcast $SNS_VIP 
       ip route add  $SNS_VIP/32 dev lo:0
       echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
       echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
       echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
       echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
       sysctl -p >/dev/null 2>&1
       echo "RealServer Start OK"
       ;;
stop)
       ip addr del $SNS_VIP/32 dev lo:0 broadcast $SNS_VIP
       ip route del  $SNS_VIP/32 dev lo:0 >/dev/null 2>&1
       echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
       echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
       echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
       echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
       echo "RealServer Stoped"
       ;;
*)
       echo "Usage: $0 {start|stop}"
       exit 1
esac
exit 0


ip addr add ${SNS_VIP}/32 dev lo:0 broadcast ${SNS_VIP}
ip route add  ${SNS_VIP}/32 dev lo:0

net.ipv4.conf.lo.arp_ignore = 1 
net.ipv4.conf.lo.arp_announce = 2 
net.ipv4.conf.all.arp_ignore = 1 
net.ipv4.conf.all.arp_announce = 2 
