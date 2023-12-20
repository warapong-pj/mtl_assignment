### install argo-cd
1. kubectl create ns argo
2. helm repo add argo https://argoproj.github.io/argo-helm
3. helm install argo-cd argo/argo-cd --values helm-values/values-argo-cd.yaml --version 5.35.1 --namespace argo --create-namespace
