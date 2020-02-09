#!/usr/bin/env bash

DEPS_LIST=("docker-machine" "docker" "minikube" "kubectl" "helm")
for item in "${DEPS_LIST[@]}"; do
  if ! command -v "$item" &> /dev/null ; then
    echo "Error: required command '$item' was not found" >&2
    exit 1
  fi
done

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -d|--destroy) DESTROY_IT="Y";;
    *) echo "Unknown parameter passed: $1" >&2; exit 1;;
  esac
  shift
done

# destroy command line
if [[ "${DESTROY_IT}" == "Y" ]]; then
  kubectl delete pv sonarqube-volume
  kubectl delete pv mysql-volume
  exit 0
fi

cat <<'EOF' | kubectl create -f -
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-volume
  labels:
    app: mysql
    type: local
spec:
  storageClassName: manual-mysql
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data/mysql"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: sonarqube-volume
  labels:
    app: sonarqube
    type: local
spec:
  storageClassName: manual-sonarqube
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data/sonarqube"
EOF
