#!/bin/bash

echo -e "\e[32mFirst Run , Dev-ops team is Installing Pre-requisites for Kubernetes\e[0m"

systemctl stop firewalld

yum update -y

yum install curl -y && yum install wget -y

swapoff -a

sudo sed -i '/swap/d' /etc/fstab

sudo setenforce 0

sudo sed -i ‘s/^SELINUX=enforcing$/SELINUX=permissive/’ /etc/selinux/config

sudo yum install -y yum-utils device-mapper-persistent-data lvm2

echo -e "\e[32mSecond Run , Dev-Ops team is installing Docker\e[0m"

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker -y

sudo systemctl start docker && sudo systemctl enable docker && sudo systemctl status docker

sudo docker version

echo -e "\e[32mThird Run , Now the Kubernetes Cluster components are being carried out\e[0m"

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

yum install -y kubeadm-1.15.0-0 kubelet-1.15.0-0 kubectl-1.15.0-0 ipvsadm

systemctl enable kubelet

systemctl start kubelet

systemctl status kubelet -l

echo -e "\e[32mFourth Run , Your Kubernetes MASTER3 is waiting , Immediately fire CONTROL_PLANE_JOINING TOKEN as ROOT user , received from MASTER1 Initialization script\e[0m"
