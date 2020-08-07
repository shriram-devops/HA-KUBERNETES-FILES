#!/bin/bash

#Script works for only Centos 7 machines

echo -e "\e[32mIMPORTANT : YOU SHOULD NOT STOP SCRIPT IN-BETWEEN , SIT BACK AND RELAX FOR NEXT 20 MINS\e[0m"

echo -e "\e[32mCAREFULLY WATCH FOR GREEN COLORED NOTICES HERE FURTHER\e[0m"

echo -e "\e[32mNotice : Make sure you have changed API-SERVER-LOAD-BALANCER-IP-ADDRESS in this script as per your environment\e[0m"

echo -e "\e[32mA************************************************************************************************************************A\e[0m"

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

echo -e "\e[32mFourth Run , Dev-Ops team is Installing Kubernetes Packages\e[0m"

yum install -y kubeadm-1.15.0-0 kubelet-1.15.0-0 kubectl-1.15.0-0 ipvsadm

systemctl enable kubelet

systemctl start kubelet

systemctl status kubelet -l

mkdir /etc/kubernetes/kubeadm

cat <<EOF > /etc/kubernetes/kubeadm/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: "IP-OF-API-SERVER-LOAD-BALANCER:6443"
networking:
  podSubnet: 
EOF

echo -e "\e[32mFifth Run , Kubernetes Cluster is Initializing\e[0m"

echo -e "\e[32mMake sure to copy and save the Joining tokens below to create more master and join worker nodes\e[0m"
	
kubeadm init --config=/etc/kubernetes/kubeadm/kubeadm-config.yaml --upload-certs

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo -e "\e[32mSixth Run , Keep Calm , Kubernetes is configuring network components\e[0m"

sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

sleep 2m 30s

sudo kubectl get nodes

sudo kubectl get pods -o wide --all-namespaces

echo -e "\e[32mSeventh Run , Kubernetes is granting you access\e[0m"

sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

sudo kubectl patch svc kubernetes-dashboard --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]' -n kubernetes-dashboard

sudo kubectl create serviceaccount dashboard -n default

sudo kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=admin --serviceaccount=default:dashboard

echo -e "\e[32mEighth Run , Please don't forget to copy below access token completely for kubernetes dashboard\e[0m"

sudo kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode

sudo kubectl get svc -o wide --all-namespaces | grep kubernetes-dashboard

echo -e "\e[32mNotedown the port followed by kubernetes dashboard service , it will be between 30000-40000 , open it in browser using https://master-ip:thisport, use the access token which you got as a output of above command\e[0m"

kubectl get nodes -o wide 

echo -e "\e[44mIf all the Nodes show in READY status\e[0m"

echo -e "\e[32mYour kubernetes cluster has initialized successfully , In case you face any issues please write an email to shriramchoudhari6@gmail.com\e[0m"

echo -e "\e[32mMaintainer : Shriram D. Choudhari , Dev-Ops Engineer - Kubernetes & Docker , Microservices\e[0m"

echo -e "\e[44mMay The Pods Be With You\e[0m"



