#helm delete --purge istio
#kubectl delete crd `kubectl get crd |grep istio|awk '{print $1}'`
kubectl delete -f manifests/istio/istio-after-helm-template.yaml
