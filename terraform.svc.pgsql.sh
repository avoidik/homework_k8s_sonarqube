#!/usr/bin/env bash

DEPS_LIST=("docker-machine" "docker" "minikube" "kubectl" "helm" "terraform")
for item in "${DEPS_LIST[@]}"; do
  if ! command -v "$item" &> /dev/null ; then
    echo "Error: required command '$item' was not found" >&2
    exit 1
  fi
done

echo -n "Apply Minikube ingress workaround (y/n): "
read -r CONFIRMATION
if [[ "${CONFIRMATION}" != "y" ]] && [[ "${CONFIRMATION}" != "Y" ]]; then
  echo "Aborted"
  exit
fi

kubectl patch configmap tcp-services \
  -n kube-system \
  -p '{"data":{"9000":"sonarqube/sonarqube-sonarqube:9000"}}'

kubectl patch deployment nginx-ingress-controller \
  -n kube-system \
  --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/ports/-", "value": {"containerPort": 9000, "protocol": "TCP", "hostPort": 9000}}]'

# open port
kubectl patch configmap tcp-services \
  -n kube-system \
  -p '{"data":{"5432":"postgresql/postgresql:5432"}}'

kubectl patch deployment nginx-ingress-controller \
  -n kube-system \
  --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/ports/-", "value": {"containerPort": 5432, "protocol": "TCP", "hostPort": 5432}}]'

kubectl get configmap tcp-services -n kube-system -o yaml
