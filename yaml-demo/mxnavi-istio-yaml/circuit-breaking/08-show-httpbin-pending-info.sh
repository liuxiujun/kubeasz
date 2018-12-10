FORTIO_POD=$(kubectl get -n demo-istio pod | grep fortio | awk '{ print $1 }')
kubectl exec -n demo-istio -it $FORTIO_POD  -c istio-proxy  -- sh -c 'curl localhost:15000/stats' | grep httpbin | grep pendin
