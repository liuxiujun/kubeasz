kubectl taint node $1 storage-node=true:NoSchedule
kubectl label nodes $1 role=storage-node
