#!/usr/bin/env bash

DEPS_LIST=("docker-machine" "docker" "minikube" "kubectl" "helm" "terraform")
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

AUTO_APPROVE="-refresh=true"

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -d|--destroy) DESTROY_IT="Y";;
    -a|--auto) AUTO_APPROVE="-auto-approve -refresh=true";;
    *) echo "Unknown parameter passed: $1" >&2; exit 1;;
  esac
  shift
done

# set profile
minikube profile "${MINICUBE_PROFILE}"

if ! terraform init -input=false . ; then
  echo "Error: Terraform init failed" >&2
  exit 0
fi

# destroy command line
if [[ "${DESTROY_IT}" == "Y" ]]; then
  export TF_WARN_OUTPUT_ERRORS=1
  terraform destroy ${AUTO_APPROVE} .
  exit 0
fi

if ! terraform apply -input=false ${AUTO_APPROVE} . ; then
  echo "Error: Terraform apply failed" >&2
  exit 0
fi

echo
echo "Please refer to README.md file for additional information on how to access the service endpoint"
echo
