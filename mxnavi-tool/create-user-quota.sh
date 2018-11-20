#!/bin/bash
# 每个对应一个namespace，用户名和namespace名称相同,同时将可以登录ui的token放在kubeconfig 中
# 注意修改KUBE_APISERVER为你的API Server的地址
KUBE_APISERVER=$1
USER=$2

#kubeapp 系统的 namespace
KUBEAPPS_NAMESPACE="kubeapps"
USAGE="USAGE: create-user.sh <api_server> <username>\n
Example: https://172.22.1.1:6443 brand"
CSR=`pwd`/user-csr.json
SSL_PATH="/etc/kubernetes/ssl"
SSL_FILES=(ca-key.pem ca.pem ca-config.json)
CERT_FILES=(${USER}.csr $USER-key.pem ${USER}.pem)

if [[ $KUBE_APISERVER == "" ]]; then
   echo -e $USAGE
   exit 1
fi
if [[ $USER == "" ]];then
    echo -e $USAGE
    exit 1
fi

# 创建用户的csr文件
function createCSR(){
cat>$CSR<<EOF
{
  "CN": "USER",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "HangZhou",
      "L": "XS",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
# 替换csr文件中的用户名
sed -i "s/USER/$USER/g" $CSR
}

function ifExist(){
if [ ! -f "$SSL_PATH/$1" ]; then
    echo "$SSL_PATH/$1 not found."
    exit 1
fi
}

# 判断证书文件是否存在
for f in ${SSL_FILES[@]};
do
    echo "Check if ssl file $f exist..."
    ifExist $f
    echo "OK"
done

echo "Create CSR file..."
createCSR
echo "$CSR created"
echo "Create user's certificates and keys..."
cd $SSL_PATH
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes $CSR| cfssljson -bare $USER
cd -

# 设置集群参数
kubectl config set-cluster kubernetes \
--certificate-authority=${SSL_PATH}/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=${USER}.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials $USER \
--client-certificate=$SSL_PATH/${USER}.pem \
--client-key=$SSL_PATH/${USER}-key.pem \
--embed-certs=true \
--kubeconfig=${USER}.kubeconfig

# 设置上下文参数
kubectl config set-context kubernetes \
--cluster=kubernetes \
--user=$USER \
--namespace=$USER \
--kubeconfig=${USER}.kubeconfig

# 设置默认上下文
kubectl config use-context kubernetes --kubeconfig=${USER}.kubeconfig

# 创建 namespace
kubectl create ns $USER

# 绑定角色
kubectl create rolebinding ${USER}-admin-binding --clusterrole=admin --user=$USER --namespace=$USER --serviceaccount=$USER:default

kubectl config get-contexts

#以下获得该用户登录页面的token
secrets_name=`kubectl get secrets  -n $USER | grep $USER | awk '{print $1}'`

ui_token=`kubectl -n $USER describe secret $secrets_name | awk '/token:/{print $2}'`
#在文件中更新登录namespace的UI
kubectl config set-credentials $USER --token=$ui_token --kubeconfig=${USER}.kubeconfig

echo "Congratulations!"
echo "Your kubeconfig file is ${USER}.kubeconfig"

#增加用户在kubeapps中的只读权限
kubectl create -n $KUBEAPPS_NAMESPACE rolebinding "$USER""-kubeapps-repositories-read" --role=kubeapps-repositories-read --serviceaccount $USER:default

#设置默认限额
kubectl create -n $USER -f ./limit-cpu.yml
kubectl create -n $USER -f ./limit-mem.yml
echo "默认限额设置为：\nCPU: 2\nMem:1Gi"

#配额设置

read -n1 -p "是否为该用户设定配额？[Y/N]：" QUOTASET
if [ $QUOTASET == "Y" -o $QUOTASET == "y" ]; then
    echo -e "\n"
    read -p "设定最小CPU配额：" RQCPU
    if [[ $RQCPU == "" ]]; then
        RQCPU=0
    fi
    read -p "设定最大CPU配额：" LMCPU
    if [[ $LMCPU == "" ]]; then
        LMCPU=0
    fi
    read -p "设定最小MEM配额：" RQMEM
    if [[ $RQMEM == "" ]]; then
        RQMEM=0
    fi
    read -p "设定最大MEM配额：" LMMEM
    if [[ $LMMEM == "" ]]; then
        LMMEM=0
    fi
    read -p "设定最大存储容量：" RQSTR
    if [[ $RQSTR == "" ]]; then
        RQSTR=0
    fi
    echo -e "注意：kubernetes 在设置配额时不做合理性验证，请确定配额设置正确：\n"
    echo -e "requests.cpu=$RQCPU requests.memory=$RQMEM limits.cpu=$LMCPU limits.memory=$LMMEM requests.storage=$RQSTR\n"
    read -n1 -p "确认配置？[Y/N]" QUOTACHECK
    if [ $QUOTACHECK == "Y" -o $QUOTACHECK == 'y' ]; then
	echo -e "\n"
        kubectl -n $USER create quota "$USER""-quota" --hard=requests.cpu=$RQCPU,requests.memory=$RQMEM,limits.cpu=$LMCPU,limits.memory=$LMMEM,requests.storage=$RQSTR
        if [ $? == 0 ]; then
            exit 1
        else
            echo -e "\n未进行配额设置。"
            exit 1
        fi
    else
        echo -e "\n\n未进行配额设置。"
    fi
else
    echo -e "\n\n未进行配额设置。"
    exit 1
fi
