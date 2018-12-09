kubectl apply -n demo-istio -f mxnavi-demo-istion/bookinfo/nginx-ingress.yaml
echo "modify you dns: bookinfo.demo-istio.mxnavi.com to nginx-ingress ip"
echo "Open: http://bookinfo.demo-istio.mxnavi.com/productpage"
