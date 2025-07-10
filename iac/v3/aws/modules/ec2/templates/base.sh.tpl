#!/bin/bash
set -eux

# ----- 공통 설치 -----
apt-get update
apt-get install -y docker.io apt-transport-https curl jq ca-certificates gnupg awscli
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

export AWS_ACCESS_KEY_ID=${access_key_id}
export AWS_SECRET_ACCESS_KEY=${secret_access_key}
export AWS_DEFAULT_REGION=${region}


# Kubernetes 설치
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
modprobe br_netfilter
sysctl net.bridge.bridge-nf-call-iptables=1

case "${node_name}" in

  "master")
    # 1) 클러스터 초기화
    kubeadm init --pod-network-cidr=10.244.0.0/16

    # 2) kubeconfig & Flannel
    mkdir -p /home/ubuntu/.kube
    cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
    chown ubuntu:ubuntu /home/ubuntu/.kube/config
    su - ubuntu -c "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"

    # 3) join 스크립트 + admin.conf → S3 업로드
    su - ubuntu -c "kubeadm token create --print-join-command > /home/ubuntu/join.sh"
    aws s3 cp /home/ubuntu/join.sh     s3://${project_name}-logs/join.sh
    aws s3 cp /etc/kubernetes/admin.conf s3://${project_name}-logs/admin.conf

    # 4) Terraform 실행
    cd /home/ubuntu/terraform
    terraform init
    terraform apply -auto-approve
    ;;

  "fe"|"be"|"ai-cpu")
    # 1) join 대기 & 실행
    until aws s3 cp s3://${project_name}-logs/join.sh /home/ubuntu/join.sh; do sleep 5; done
    bash /home/ubuntu/join.sh

    # 2) kubeconfig 다운로드 & 권한 설정
    mkdir -p /home/ubuntu/.kube
    until aws s3 cp s3://${project_name}-logs/admin.conf /home/ubuntu/.kube/config; do sleep 5; done
    chown -R ubuntu:ubuntu /home/ubuntu/.kube
    export KUBECONFIG=/home/ubuntu/.kube/config

    # 3) ECR 로그인 (컨테이너 + Helm)
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    aws ecr get-login-password --region ${region} \
      | docker login --username AWS --password-stdin $${ACCOUNT_ID}.dkr.ecr.${region}.amazonaws.com
    aws ecr get-login-password --region ${region} \
      | helm registry login --username AWS --password-stdin $${ACCOUNT_ID}.dkr.ecr.${region}.amazonaws.com

    # # 4) Helm 차트 설치
    # if [ "${node_name}" = "k8s-worker-fe" ]; then
    #   helm install frontend \
    #     oci://$${ACCOUNT_ID}.dkr.ecr.${region}.amazonaws.com/${project_name}-charts/frontend \
    #     --version latest \
    #     --create-namespace --namespace frontend
    # else
    #   helm install backend \
    #     oci://$${ACCOUNT_ID}.dkr.ecr.${region}.amazonaws.com/${project_name}-charts/backend \
    #     --version latest \
    #     --create-namespace --namespace backend
    # fi
    ;;

  "monitoring")
    # 1) 클러스터 조인
    until aws s3 cp s3://${project_name}-logs/join.sh /home/ubuntu/join.sh; do sleep 5; done
    bash /home/ubuntu/join.sh

    # 2) kubeconfig 다운로드
    mkdir -p /home/ubuntu/.kube
    until aws s3 cp s3://${project_name}-logs/admin.conf /home/ubuntu/.kube/config; do sleep 5; done
    chown -R ubuntu:ubuntu /home/ubuntu/.kube
    export KUBECONFIG=/home/ubuntu/.kube/config

    # 3) Prometheus/Grafana 모니터링 스택
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install monitoring \
      prometheus-community/kube-prometheus-stack \
      --create-namespace --namespace monitoring

    # 4) Loki (로그 수집) 서버 및 Agent
    helm install loki \
      grafana/loki-stack \
      --namespace monitoring \
      --set promtail.enabled=true \
      --set promtail.serviceMonitor.enabled=true

    # 5) Jaeger (트레이스 수집) all-in-one 배포
    helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
    helm repo update
    helm install jaeger \
      jaegertracing/jaeger \
      --namespace monitoring \
      --set provisionDataStore.cassandra=false \
      --set provisionDataStore.elasticsearch=false \
      --set collector.agent.enabled=true
    ;;

  "argocd")
    # 1) 클러스터 조인
    until aws s3 cp s3://${project_name}-logs/join.sh /home/ubuntu/join.sh; do sleep 5; done
    bash /home/ubuntu/join.sh

    # 2) kubeconfig 다운로드
    mkdir -p /home/ubuntu/.kube
    until aws s3 cp s3://${project_name}-logs/admin.conf /home/ubuntu/.kube/config; do sleep 5; done
    chown -R ubuntu:ubuntu /home/ubuntu/.kube
    export KUBECONFIG=/home/ubuntu/.kube/config

    # 3) Argo CD 설치
    kubectl create namespace argocd || true
    kubectl apply -n argocd \
      -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ;;

  "redis-master"|"redis-slave")
    # 1) 클러스터 조인
    until aws s3 cp s3://${project_name}-logs/join.sh /home/ubuntu/join.sh; do sleep 5; done
    bash /home/ubuntu/join.sh

    # 2) kubeconfig 다운로드
    mkdir -p /home/ubuntu/.kube
    until aws s3 cp s3://${project_name}-logs/admin.conf /home/ubuntu/.kube/config; do sleep 5; done
    chown -R ubuntu:ubuntu /home/ubuntu/.kube
    export KUBECONFIG=/home/ubuntu/.kube/config

    # 2) Redis 설치
    kubectl create namespace redis || true

    # Redis 설치 (Bitnami Chart)
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update

    helm install my-redis bitnami/redis \
      --namespace redis \
      --set auth.enabled=false
    ;;

esac
