echo "-------------------------------"
echo "使用kubectl命令"
echo "-------------------------------"
kubectl get -n demo-istio  destinationrule
kubectl get -n demo-istio  virtualservices


echo "-------------------------------"
echo "可以使用 istioctl 命令，显示更详细"
echo "-------------------------------"
istioctl get -n demo-istio destinationrule
istioctl get -n demo-istio virtualservice
