#!/bin/bash
set -eux

# ----- 공통 설치 -----
apt-get update
apt-get install -y docker.io apt-transport-https curl awscli jq

# Kubernetes 설치
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
sysctl net.bridge.bridge-nf-call-iptables=1

case "${node_name}" in

  "k8s-master")
    # Master 초기화 및 Flannel 설치
    kubeadm init --pod-network-cidr=10.244.0.0/16
    mkdir -p /home/ubuntu/.kube
    cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
    chown ubuntu:ubuntu /home/ubuntu/.kube/config
    su - ubuntu -c "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"

    # join 스크립트 생성 후 S3 업로드
    su - ubuntu -c "kubeadm token create --print-join-command > /home/ubuntu/join.sh"
    aws s3 cp /home/ubuntu/join.sh s3://${project_name}-scripts/join.sh
    ;;

  "k8s-worker")
    # Master join
    until aws s3 cp s3://${project_name}-scripts/join.sh /home/ubuntu/join.sh; do sleep 5; done
    bash /home/ubuntu/join.sh
    ;;

  "grafana-prometheus")
    # kubeconfig 준비
    until test -f /home/ubuntu/.kube/config; do sleep 10; done
    export KUBECONFIG=/home/ubuntu/.kube/config

    # Helm 설치
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    # 공식 Helm 차트 리포지토리 등록
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana              https://grafana.github.io/helm-charts
    helm repo update

    # 차트 설치 (public repo)
    helm install prometheus prometheus-community/prometheus
    helm install grafana    grafana/grafana --set adminPassword="admin"
    ;;


  "argocd")
    # kubeconfig 준비
    until test -f /home/ubuntu/.kube/config; do sleep 10; done
    export KUBECONFIG=/home/ubuntu/.kube/config

    # Argo CD 설치
    kubectl create namespace argocd || true
    kubectl apply -n argocd \
      -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ;;
esac