NAMESPACE="zhangyi"
USERNAME="zhangyi-user"



#ROLE NAME 自动生成即可
ROLE_BINDING_NAME="rolebinding-""$NAMESPACE""-""$USERNAME"

#创建namespace
kubectl create namespace $NAMESPACE

#在该namespace下创建用户
kubectl create serviceaccount $USERNAME -n $NAMESPACE

#将该空间的admin权限给予该用户
kubectl create rolebinding $ROLE_BINDING_NAME --clusterrole=admin --serviceaccount=$NAMESPACE:$USERNAME --namespace=$NAMESPACE

#以下获得该用户登录页面的token
secrets_name=`kubectl get secrets  -n $NAMESPACE | grep $USERNAME | awk '{print $1}'`

echo "可以使用如下token 进行登录"
kubectl -n $NAMESPACE describe secret $secrets_name | awk '/token:/{print $2}'
