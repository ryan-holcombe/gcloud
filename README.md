# gcloud

## Requires a credentials.json file to be present for external dns IAM permissions

## Run the following to create a service account for Helm Tiller
```
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
helm init --service-account tiller --upgrade
```

## Run the following to allow helm to view pods in kube-system
```
kubectl create clusterrolebinding kube-system-default-admin --clusterrole=cluster-admin --serviceaccount=default:default
```

## Kubernetes secrets

#### Gcloud Account
requires a `credentials.json` file to be present which represents the IAM account that will be executing terraform resources

#### Docker Registry
requires a `dockercreds.json` config file

#### Cert Manager ClusterIssuer
```
kubectl create -f letsencrypt-clusterissuer-prod.yml
```
