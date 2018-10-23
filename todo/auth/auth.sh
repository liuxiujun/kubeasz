export KUBEAPPS_NAMESPACE=kubeapps

kubectl apply -n $KUBEAPPS_NAMESPACE -f ./kubeapps-repositories-read.yaml

#kubectl create -n reidai rolebinding example-edit \
#  --clusterrole=edit \
#  --serviceaccount reidai:default

kubectl create -n $KUBEAPPS_NAMESPACE rolebinding example-kubeapps-repositories-read \
  --role=kubeapps-repositories-read \
  --serviceaccount reidai:default
