FORTIO_POD=$(kubectl get -n demo-istio pod | grep fortio | awk '{ print $1 }')
kubectl exec -n demo-istio -it $FORTIO_POD  -c fortio /usr/local/bin/fortio -- load -curl  http://httpbin:8000/get
