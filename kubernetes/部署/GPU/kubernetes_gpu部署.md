# kubernetes 1.11ʹ��GPU���ֲ�
1. ��װnvidia������yum��װ��
+ 1.1���빫Կ
```
# rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
```

+ 1.2 ��װelrepo
```
# rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
```

+ 1.3 ��װfastestmirror
```
yum install yum-plugin-fastestmirror
```

+ 1.4 ����Ĭ�ϴ��е�nouveau
```
vim /lib/modprobe.d/dist-blacklist.conf
��nvidiafbע�͵�
#blacklist nvidiafb
���������䣺
blacklist nouveau
options nouveau modeset=0
```

+ 1.5 �ؽ�initramfs image
```
# mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.bak
# dracut /boot/initramfs-$(uname -r).img $(uname -r)
```

+ 1.6 �������������鿴nouveau�Ƿ��Ѿ�����
```
# lsmod | grep nouveau
```

+ 1.7 ��װNvidia�Կ�����
```
# yum install nvidia-detect
# nvidia-detect -v
# yum -y install kmod-nvidia
```

ȷ�Ͻ��
```
# nvidia-smi 
```

2. ��װnvidia-docker2.

```
# yum install nvidia-docker2
```
��װ��֮���޸�/etc/docker/daemon.json
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

����docker������֤nvidia-docker��װ��ȷ
```
# systemctl restart docker
# docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
```

3. ��װnvidia-device-plugin��ֻ��nvidia-device-plugin.yml��gpu�ڵ㣨��gpu=true��label��������nvidia-device-plugin.
```
# kubectl create -f nvidia-device-plugin.yml
```
����gpu�ڵ�Ϳ����ϱ�gpu��Դ�ˡ�

�ϱ�������£�
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

4. ����ʹ��gpu��Դ��pod
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