#!/usr/bin/env bash

DEPS_LIST=("docker-machine" "docker" "minikube" "kubectl" "helm")
for item in "${DEPS_LIST[@]}"; do
  if ! command -v "$item" &> /dev/null ; then
    echo "Error: required command '$item' was not found" >&2
    exit 1
  fi
done

if [ ! -f ".env" ]; then
  echo "Error: environment definition is missing" >&2
  exit 1
fi

source ./.env

if [ -z "${MINICUBE_PROFILE}" ]; then
  echo "Error: environment definition is missing" >&2
  exit 1
fi

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -d|--destroy) DESTROY_IT="Y";;
    *) echo "Unknown parameter passed: $1" >&2; exit 1;;
  esac
  shift
done

# set profile
minikube profile "${MINICUBE_PROFILE}"

# destroy command line
if [[ "${DESTROY_IT}" == "Y" ]]; then
  minikube delete
  exit 0
fi

# windows workaround
export MSYS2_ARG_CONV_EXCL="*"

# create cluster
minikube start \
  --vm-driver='virtualbox' \
  --extra-config='apiserver.authorization-mode=Node,RBAC' \
  --extra-config='apiserver.runtime-config=events.k8s.io/v1beta1=false' \
  --extra-config='kubelet.authentication-token-webhook=true' \
  --extra-config='apiserver.service-account-signing-key-file=/var/lib/minikube/certs/sa.key' \
  --extra-config='apiserver.service-account-key-file=/var/lib/minikube/certs/sa.pub' \
  --extra-config='apiserver.service-account-issuer=api' \
  --extra-config='apiserver.service-account-api-audiences=api' \
  --kubernetes-version='v1.17.0' \
  --memory 4096 || {
  echo "Error: no minikube cluster was created" >&2
  exit 1
}

# show ip
echo "Minikube cluster IP address is:"
minikube ip

# enable nginx ingress
minikube addons enable ingress

# add helm repo
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update
