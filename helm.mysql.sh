#!/usr/bin/env bash

NAME_SPACE="mysql"
HELM_CHART="stable/mysql"
HELM_VER="1.6.2"
HELM_NAME="${NAME_SPACE}"
HOST_PORT="3306"

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
  helm status "${HELM_NAME}" -n "${NAME_SPACE}" &> /dev/null && {
    helm uninstall "${HELM_NAME}" -n "${NAME_SPACE}"
    kubectl delete ns "${NAME_SPACE}"
  }
  exit 0
fi

# create namespace
kubectl create ns "${NAME_SPACE}" || { echo "Error: namespace exist" >&2; exit 1; }

# chart info
helm show chart "${HELM_CHART}" || { echo "Error: chart does not exist" >&2; exit 1; }

# install helm mysql chart
helm install \
  "${HELM_NAME}" \
  "${HELM_CHART}" \
  --values values/mysql.yaml \
  --namespace "${NAME_SPACE}" \
  --version "${HELM_VER}" \
  --atomic || {
  kubectl delete ns "${NAME_SPACE}"
  exit 1
}

helm list -n "${NAME_SPACE}"

# open port
kubectl patch configmap tcp-services \
  -n kube-system \
  -p "{\"data\":{\"${HOST_PORT}\":\"${NAME_SPACE}/${HELM_NAME}:${HOST_PORT}\"}}"

kubectl patch deployment nginx-ingress-controller \
  -n kube-system \
  -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"nginx-ingress-controller\",\"ports\":[{\"containerPort\":${HOST_PORT},\"protocol\":\"TCP\",\"hostPort\":${HOST_PORT}}]}]}}}}"

# kubectl patch deployment nginx-ingress-controller \
#   -n kube-system \
#   --type='json' \
#   -p="[{\"op\": \"add\", \"path\": \"/spec/template/spec/containers/0/ports/-\", \"value\": {\"containerPort\": ${HOST_PORT}, \"protocol\": \"TCP\", \"hostPort\": ${HOST_PORT}}}]"

kubectl get configmap tcp-services -n kube-system -o yaml
