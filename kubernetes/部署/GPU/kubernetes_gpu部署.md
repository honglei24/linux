# kubernetes 1.11使用GPU的手册
1. 安装nvidia驱动（yum安装）
+ 1.1导入公钥
```
# rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
```

+ 1.2 安装elrepo
```
# rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
```

+ 1.3 安装fastestmirror
```
yum install yum-plugin-fastestmirror
```

+ 1.4 屏蔽默认带有的nouveau
```
vim /lib/modprobe.d/dist-blacklist.conf
将nvidiafb注释掉
#blacklist nvidiafb
添加以下语句：
blacklist nouveau
options nouveau modeset=0
```

+ 1.5 重建initramfs image
```
# mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.bak
# dracut /boot/initramfs-$(uname -r).img $(uname -r)
```

+ 1.6 重启服务器，查看nouveau是否已经禁用
```
# lsmod | grep nouveau
```

+ 1.7 安装Nvidia显卡驱动
```
# yum install nvidia-detect
# nvidia-detect -v
# yum -y install kmod-nvidia
```

确认结果
```
# nvidia-smi 
```

2. 安装nvidia-docker2.

```
# yum install nvidia-docker2
```
安装完之后修改/etc/docker/daemon.json
```
# vi /etc/docker/daemon.json
{
   "default-runtime": "nvidia",
   "runtimes": {
       "nvidia": {
           "path": "/usr/bin/nvidia-container-runtime",
           "runtimeArgs": []
       }
   }
}
```

重启docker，并验证nvidia-docker安装正确
```
# systemctl restart docker
# docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
```

3. 安装nvidia-device-plugin，只用nvidia-device-plugin.yml在gpu节点（带gpu=true的label）上启动nvidia-device-plugin.
```
# kubectl create -f nvidia-device-plugin.yml
```
这样gpu节点就可以上报gpu资源了。

上报结果如下：
```
...
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource        Requests  Limits
  --------        --------  ------
  cpu             0 (0%)    0 (0%)
  memory          0 (0%)    0 (0%)
  <strong>nvidia.com/gpu  0         0</strong>
...
```

4. 创建使用gpu资源的pod
```
# vim gpu_pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  hostNetwork: true
  containers:
    - name: cuda-container
      image: nvidia/cuda:9.0-devel
      resources:
        limits:
          nvidia.com/gpu: 1 


# kubectl -f create gpu_pod.yaml
```