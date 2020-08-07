#!/bin/bash

#Below Script has been tested on Centos 7 servers , make sure you have new or clean Centos 7 machine

echo -e "\e[32mThis script is contribution of Shriram D. Choudhari for the Kubernetes On premise new learners\e[0m"

echo -e "\e[32mYou are running script for Installing HAProxy as your API server Load Balancer for HA-Kubernetes-Masters\e[0m"

echo -e "\e[32mMake sure you have to use a dedicated centos 7 machine for this , Do not use any of Kubernetes Master or Worker nodes\e[0m"

yum update -y

systemctl stop firewalld

sudo sed -i ‘s/^SELINUX=enforcing$/SELINUX=permissive/’ /etc/selinux/config

setsebool -P haproxy_connect_any=1

yum install haproxy -y

mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.original

cat <<EOF > /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #y

    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     400000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
#    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 300000

#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------

frontend k8s-api
    bind IP-ADDRESS-OF-YOUR-LOAD-BALANCER-MACHINE:6443
    bind 127.0.0.1:6443
    mode tcp
    option tcplog
    timeout client 300000
    default_backend k8s-api

backend k8s-api
    mode tcp
    option tcplog
    option tcp-check
        timeout server 300000
    balance roundrobin
    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 2500 maxqueue 2560 weight 100
        stats enable
        server ha-kmaster1 IP-ADDRESS-OF-MASTER1:6443 check
        server ha-kmaster2 IP-ADDRESS-OF-MASTER2:6443 check
        server ha-kmaster3 IP-ADDRESS-OF-MASTER3:6443 check

#--------------------------------------------------------------------------------------------------------------
#Lines below are statistics dashboard arrangements for HA-proxy stats
#--------------------------------------------------------------------------------------------------------------

listen stats
    bind :8404
    stats enable
    stats uri /
    stats hide-version
    stats auth admin:admin
EOF

echo -e "\e[32mMake sure you have changed all IP addresses in the script accordingly\e[0m"

cat /etc/haproxy/haproxy.cfg

echo -e "\e[32mIf everything is fine fire below commands as root user\e[0m"

echo -e "\e[32msudo systemctl daemon-reload\e[0m"

echo -e "\e[32msudo systemctl enable haproxy\e[0m"

echo -e "\e[32msudo systemctl start haproxy\e[0m"

echo -e "\e[32msudo systemctl status haproxy -l\e[0m"

echo -e "\e[32mTo allow HAproxy stats dashboard and logs do as mentioned in global section point 1) and 2)\e[0m"

echo -e "\e[32mStats Dashboard is available at http://YOUR-This-Server-IP:8404/stats\e[0m"
