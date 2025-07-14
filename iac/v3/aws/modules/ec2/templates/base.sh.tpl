#!/bin/bash
set -eux

# ----- 공통 설치 -----
sudo yum update -y
# Docker 설치 및 활성화
sudo yum install -y docker jq ca-certificates gnupg awscli
sudo systemctl enable docker
sudo systemctl start docker

# Helm 설치
sudo echo "Installing Helm..."
sudo curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Kubernetes 설치를 위한 YUM 리포지토리 설정
sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/repodata/repomd.xml.key
EOF


# kubelet, kubeadm, kubectl 설치
sudo yum install -y kubelet kubeadm kubectl
sudo systemctl enable kubelet

# k8s 설정값 변경
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

# netfilter 설정 (Bridge 트래픽 허용)
sudo modprobe br_netfilter
sudo sysctl --system


case "${node_name}" in

  "master")
    # 1) 클러스터 초기화
    kubeadm init --pod-network-cidr=10.244.0.0/16

    # 2) kubeconfig & Flannel 적용
    mkdir -p /home/ec2-user/.kube
    cp -i /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
    chown ec2-user:ec2-user /home/ec2-user/.kube/config
    kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

    # 3) join 스크립트 및 config → S3 업로드
    kubeadm token create --print-join-command > /home/ec2-user/join.sh
    aws s3 cp /home/ec2-user/join.sh s3://${project_name}-logs/join.sh
    aws s3 cp /home/ec2-user/.kube/config s3://${project_name}-logs/admin.conf

    # 4) Terraform 적용 (선택)
    cd /home/ec2-user/terraform
    terraform init
    terraform apply -auto-approve
    ;;

  "fe"|"be"|"ai-cpu")
    # 1) join 대기 & 실행
    until aws s3 cp s3://${project_name}-logs/join.sh /home/ec2-user/join.sh; do sleep 5; done
    bash /home/ec2-user/join.sh

    # 2) kubeconfig 설정
    mkdir -p /home/ec2-user/.kube
    until aws s3 cp s3://${project_name}-logs/admin.conf /home/ec2-user/.kube/config; do sleep 5; done
    chown -R ec2-user:ec2-user /home/ec2-user/.kube
    export KUBECONFIG=/home/ec2-user/.kube/config

    # 3) ECR 로그인 (Docker & Helm)
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    aws ecr get-login-password --region ${region} \
      | docker login --username AWS --password-stdin $$ACCOUNT_ID.dkr.ecr.${region}.amazonaws.com
    aws ecr get-login-password --region ${region} \
      | helm registry login --username AWS --password-stdin $$ACCOUNT_ID.dkr.ecr.${region}.amazonaws.com

    # 4) Helm 차트 설치 (주석 해제 후 사용)
    # if [ "${node_name}" = "fe" ]; then
    #   helm install frontend oci://$${ACCOUNT_ID}.dkr.ecr.${region}.amazonaws.com/${project_name}-charts/frontend --version latest --create-namespace --namespace frontend
    # else
    #   helm install backend  oci://$${ACCOUNT_ID}.dkr.ecr.${region}.amazonaws.com/${project_name}-charts/backend  --version latest --create-namespace --namespace backend
    # fi
    ;;

  "monitoring")
    # 1) join 대기 & 실행
    until aws s3 cp s3://${project_name}-logs/join.sh /home/ec2-user/join.sh; do sleep 5; done
    bash /home/ec2-user/join.sh

    # 2) kubeconfig 설정
    mkdir -p /home/ec2-user/.kube
    until aws s3 cp s3://${project_name}-logs/admin.conf /home/ec2-user/.kube/config; do sleep 5; done
    chown -R ec2-user:ec2-user /home/ec2-user/.kube
    export KUBECONFIG=/home/ec2-user/.kube/config

    # 3) Prometheus/Grafana 스택 설치
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install monitoring prometheus-community/kube-prometheus-stack --create-namespace --namespace monitoring

    # 4) Loki 설치
    helm install loki grafana/loki-stack --namespace monitoring --set promtail.enabled=true --set promtail.serviceMonitor.enabled=true

    # 5) Jaeger 설치
    helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
    helm repo update
    helm install jaeger jaegertracing/jaeger --namespace monitoring --set provisionDataStore.cassandra=false --set provisionDataStore.elasticsearch=false --set collector.agent.enabled=true
    ;;

  "argocd")
    # 1) join 대기 & 실행
    until aws s3 cp s3://${project_name}-logs/join.sh /home/ec2-user/join.sh; do sleep 5; done
    bash /home/ec2-user/join.sh

    # 2) kubeconfig 설정
    mkdir -p /home/ec2-user/.kube
    until aws s3 cp s3://${project_name}-logs/admin.conf /home/ec2-user/.kube/config; do sleep 5; done
    chown -R ec2-user:ec2-user /home/ec2-user/.kube
    export KUBECONFIG=/home/ec2-user/.kube/config

    # 3) Argo CD 설치
    kubectl create namespace argocd || true
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ;;

  "redis-master"|"redis-slave")
    # 1) join 대기 & 실행
    until aws s3 cp s3://${project_name}-logs/join.sh /home/ec2-user/join.sh; do sleep 5; done
    bash /home/ec2-user/join.sh

    # 2) kubeconfig 설정
    mkdir -p /home/ec2-user/.kube
    until aws s3 cp s3://${project_name}-logs/admin.conf /home/ec2-user/.kube/config; do sleep 5; done
    chown -R ec2-user:ec2-user /home/ec2-user/.kube
    export KUBECONFIG=/home/ec2-user/.kube/config

    # 3) Redis 설치 (Bitnami Chart)
    kubectl create namespace redis || true
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    helm install my-redis bitnami/redis --namespace redis --set auth.enabled=false
    ;;

esac
