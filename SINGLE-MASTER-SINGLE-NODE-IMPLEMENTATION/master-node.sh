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

serverip=`/sbin/ifconfig eth0 | grep "inet" | awk '{print $2}' | awk 'NR==1' | cut -d':' -f2`

echo $serverip

sudo kubeadm init --apiserver-advertise-address=$serverip

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo -e "\e[32mFourth Run , Keep Calm , Kubernetes is configuring network components\e[0m"

sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

sleep 2m 30s

sudo kubectl get nodes

sudo kubectl get pods -o wide --all-namespaces

echo -e "\e[32mFifth Run , Kubernetes is granting you access\e[0m"

sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

sudo kubectl patch svc kubernetes-dashboard --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]' -n kubernetes-dashboard

sudo kubectl create serviceaccount dashboard -n default

sudo kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=admin --serviceaccount=default:dashboard

echo -e "\e[32mSixth Run , Please don't forget to copy below access token for kubernetes dashboard\e[0m"

sudo kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode

sudo kubectl get svc -o wide --all-namespaces | grep kubernetes-dashboard

echo -e "\e[32mNotedown the port followed by kubernetes dashboard service , it will be between 30000-40000 , open it in browser using https://master-ip:thisport, use the access token which you got as a output of above command\e[0m"

echo -e "\e[32mBelow is your joining token to bootstrap a new worker node inside cluster , save it and fire it inside worker node terminal\e[0m"

echo -e "\e[32mYou need to fire below joining token on worker nodes immediately after completion of worker script\e[0m"

echo -e "\e[32mLast Run , Make sure that until you fire below token on worker node , your cluster won't be fully functional\e[0m"

sudo kubeadm token create --print-join-command 

echo -e "\e[32mWait until all nodes show ready status\e[0m"

sleep 2m 30s

sudo kubectl get nodes -o wide

echo -e "\e[32mYour kubernetes cluster has initialized successfully , In case you face any issues please write an email to shriram.choudhari@roche.com\e[0m"

echo -e "\e[32mMaintainer : Shriram D. Choudhari , Dev-Ops Engineer - Kubernetes & Docker , Microservices\e[0m"

echo -e "\e[44mMay The Pods Be With You\e[0m" 




