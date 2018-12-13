#一、k8s删除节点

#https://blog.csdn.net/liumiaocn/article/details/73997635

#直接让某个节点不可用，同时驱逐上面的pod
#kubectl drain $ip

# 只让node上不可以调度，原来的pod还存在
#让某个节点不可以调度
#kubectl cordon $ip
#让某个节点重新恢复
#kubectl uncordon $ip

# 只驱逐node上的pod
#强制使该机器上的pod，迁移到其他节点
#kubectl taint node [node] key=value[effect]   
#     其中[effect] 可取值： [ NoSchedule | PreferNoSchedule | NoExecute ]
#      NoSchedule ：一定不能被调度。POD 不会被调度到标记为 taints 节点。
#      PreferNoSchedule：尽量不要调度。NoSchedule 的软策略版本。
#      NoExecute：不仅不会调度，还会驱逐Node上已有的Pod。
# 示例：kubectl taint node 192.168.56.11 key1=value1:NoSchedule

# kubectl taint node $ip bedelete=true:NoExecute

#二、calico 删除节点
#https://docs.projectcalico.org/v3.2/usage/decommissioning-a-node
#calicoctl delete node
