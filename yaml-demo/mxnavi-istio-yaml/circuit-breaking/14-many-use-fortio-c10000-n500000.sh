FORTIO_POD=$(kubectl get -n demo-istio pod | grep fortio | awk '{ print $1 }')

for p in $FORTIO_POD
do

nohup kubectl exec -n demo-istio -it $p  -c fortio /usr/local/bin/fortio -- load -c 10000 -qps 0 -n 500000 -loglevel Warning http://httpbin:8000/get > ~/$p.log &

done

exit 1
kubectl exec -n demo-istio -it $FORTIO_POD  -c fortio /usr/local/bin/fortio -- load -c 10000 -qps 0 -n 500000 -loglevel Warning http://httpbin:8000/get &
