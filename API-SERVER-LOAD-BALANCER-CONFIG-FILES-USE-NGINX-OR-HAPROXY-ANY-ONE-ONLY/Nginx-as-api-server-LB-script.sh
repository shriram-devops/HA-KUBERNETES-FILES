#!/bin/bash

echo -e "\e[32mThis script is contribution of Shriram D. Choudhari for the Kubernetes On premise new learners\e[0m"

echo -e "\e[32mYou are running script for Installing HAProxy as your API server Load Balancer for HA-Kubernetes-Masters\e[0m"

echo -e "\e[32mMake sure you have to use a dedicated centos 7 machine for this , Do not use any of Kubernetes Master or Worker nodes\e[0m"

sudo yum update -y

sudo systemctl stop firewalld

sudo yum install nginx -y 

sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original

sudo cat <<EOF > /etc/nginx/nginx.conf
events { }
stream {
upstream stream_backend {
least_conn;
server IP-ADDRESS-OF-MASTER1:6443;
server IP-ADDRESS-OF-MASTER2:6443;
server IP-ADDRESS-OF-MASTER3:6443;
}

server {
listen        6443;
proxy_pass    stream_backend;
}
}
EOF

echo -e "\e[32mMake sure you have changed IP addresses as per your environment , you can change it in /etc/nginx/nginx.conf\e[0m"

sudo cat /etc/nginx/nginx.conf

echo -e "\e[32mIf everything is fine fire below commands as root user\e[0m"

echo -e "\e[32msystemctl daemon-reload\e[0m"

echo -e "\e[32msystemctl enable nginx\e[0m"

echo -e "\e[32msystemctl start nginx\e[0m"

echo -e "\e[32msystemctl status nginx -l\e[0m"
