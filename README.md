# K8s

## SonarQube + MySQL

In this exercise we will install SonarQube with MySQL on a local Kubernetes cluster atop Minikube

Please keep in mind, SonarQube 7.9 and above does not support MySQL backend! Therefore, the latest version of SonarQube supported MySQL backend is 7.8. Check `feature/postgresql` branch if you wanted to use latest version of SonarQube.

Tiller is obsolete in Helm 3, hence not presented in this exercise.

The deployment process is as follows

1. Run Minikube cluster
1. Configure Helm
1. Deploy MySQL chart into a separate namespace with data persistance
1. Deploy SonarQube chart into a separate namespace with data persistance
1. Configure Ingress for both MySQL and SonarQube

On a first try the deployment process may take up to 5 minutes (e.g. images downloading).

## Prerequisites

- [Terraform](https://www.terraform.io/)
- [Helm](https://github.com/helm/helm/releases)
- [Docker](https://hub.docker.com/search?offering=community&q=&type=edition)
- [Docker-Machine](https://github.com/docker/machine/releases)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [minikube](https://github.com/kubernetes/minikube/releases)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Minikube

Start Minikube cluster

```bash
./minikube.sh
```

Terminate Minikube cluster

```bash
./minikube.sh --destroy
```

*Optionally you may change Minikube's profile inside .env file*

## Terraform

Initiate deployment

```bash
./terraform.sh --auto
```

Terminate deployment

```bash
./terraform.sh --auto --destroy
```

*The `--auto` flag is optional*

## Shell scripts

Initiate deployment

```bash
./helm.mysql.sh
./helm.sonarqube.sh
```

Terminate deployment

```bash
./helm.sonarqube.sh --destroy
./helm.mysql.sh --destroy
```

## Accessing services

Additional changes might be required to expose service ports through Minikube, and access SonarQube or MySQL from your local machine.

At your convenience there are three options available:

1. With Shell automation - applied automatically
1. With Terraform automation - use `terraform.svc.mysql.sh`
1. Manually, check steps below

### Ingress as Minikube addon

```bash
# enable addon
minikube addons enable ingress

# patch up ports
kubectl patch configmap tcp-services \
  -n kube-system \
  -p '{"data":{"3306":"mysql/mysql:3306"}}'

kubectl patch deployment nginx-ingress-controller \
  -n kube-system \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx-ingress-controller","ports":[{"containerPort":3306,"protocol":"TCP","hostPort":3306}]}]}}}}'

# OR

kubectl patch deployment nginx-ingress-controller \
  -n kube-system \
  --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/ports/-", "value": {"containerPort": 3306, "protocol": "TCP", "hostPort": 3306}}]'
```

### Ingress as not an Minikube addon

```bash
# disable addon
minikube addons disable ingress

# install ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl get deploy nginx-ingress-controller -n ingress-nginx

# patch up ports
kubectl patch deployment nginx-ingress-controller \
  -n ingress-nginx \
  -p '{"spec":{"template":{"spec":{"hostNetwork":true}}}}'

kubectl patch configmap tcp-services \
  -n ingress-nginx \
  -p '{"data":{"3306":"mysql/mysql:3306"}}'

kubectl get configmap tcp-services \
  -n ingress-nginx -o yaml
```

## URL

After successfull deployment you will be able to access SonarQube at:

```bash
echo "http://$(minikube ip):9000"
```

You may use standard admin/admin credentials to login.

## HeidiSQL

You may use free [HeidiSQL](https://www.heidisql.com/) to connect to PostgreSQL database. Just import preconfigured profile from `heidisql/minikube-mysql.txt`

*Please support HeidiSQL author with the donation*

## Copyright

You may use my work or its parts as you wish, but only with the proper credits to me like this:

Viacheslav - avoidik@gmail.com
