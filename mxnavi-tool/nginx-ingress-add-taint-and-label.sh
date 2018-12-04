kubectl taint node $1 nginx-ingress=true:NoSchedule
kubectl label nodes $1 role=nginx-ingress
