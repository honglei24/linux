# 在已知的kubernetes环境上生成一个config文件

## 前提条件
1. 以下手册针对kubernetes1.11。
2. 需要在kubelet启动参数里加上--dynamic-config-dir=<dynamic_dir>, dynamic_dir必须是一个可写目录。

## 操作手册

```
# yum install jq
# kubectl proxy --port=8001 &
# export NODE_NAME="kube-node03"
# curl -sSL "http://localhost:8001/api/v1/nodes/${NODE_NAME}/proxy/configz" | jq '.kubeletconfig|.kind="KubeletConfiguration"|.apiVersion="kubelet.config.k8s.io/v1beta1"' > kubelet_configz_${NODE_NAME}
# kubectl -n kube-system create configmap my-node-config --from-file=kubelet=kubelet_configz_${NODE_NAME} --append-hash -o yaml
# kubectl edit node ${NODE_NAME}
......
spec:
  externalID: kube-node03
  configSource:
    configMap:
      name: my-node-config-6gccd52b6d
      namespace: kube-system
      kubeletConfigKey: kubelet
......
```

## 后续操作
等待kubelet重启完成。会在<dynamic_dir>/store/checkpoints/*/*/目录下会有一个配置文件，可以将该文件拷贝到一个固定目录，并在kubelet配置里指定--config后的文件为该文件。
重启kubelet
