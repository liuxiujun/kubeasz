set -x
if [ "$1" == "" ];then
  echo "输入namespace"
  exit 1
fi
FORTIO_POD=$(kubectl get pod -n $1 | grep fortio | awk '{ print $1 }')
kubectl exec -n $1 -it $FORTIO_POD  -c fortio /usr/local/bin/fortio -- load -c 5 -qps 0 -n 3000 -loglevel Warning http://service-c.demo.k8s-project.mxnavi.com/
