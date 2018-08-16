## 现象
kubernetes集群报no space left on device 的错误。错误形式如下：
```
kubelet.ns-k8s-node001.root.log.ERROR.20180214-113740.15702:1593018:E0320 04:59:09.572336 15702 remote_runtime.go:92] RunPodSandbox from runtime service failed: rpc error: code = Unknown desc = failed to start sa
ndbox container for pod "osp-xxx-com-ljqm19-54bf7678b8-bvz9s": Error response from daemon: oci runtime error: container_linux.go:247: starting container process caused "process_linux.go:258: applying cgroup configuration
for process caused \"mkdir /sys/fs/cgroup/memory/kubepods/burstable/podf1bd9e87-1ef2-11e8-afd3-fa163ecf2dce/8710c146b3c8b52f5da62e222273703b1e3d54a6a6270a0ea7ce1b194f1b5053: no space left on device\""
```

## 造成原因
```
k8s.io/kubernetes/vendor/github.com/opencontainers/runc/libcontainer/cgroups/fs/memory.go

-		if d.config.KernelMemory != 0 {
+			// Only enable kernel memory accouting when this cgroup
+			// is created by libcontainer, otherwise we might get
+			// error when people use `cgroupsPath` to join an existed
+			// cgroup whose kernel memory is not initialized.
 			if err := EnableKernelMemoryAccounting(path); err != nil {
 				return err
 			}
```
1.9版删除了一行代码，表明cgroup kernel memory 特性被激活了。在出问题的机器上可以查看到：
```
# cat  /sys/fs/cgroup/memory/kubepods/memory.kmem.slabinfo 
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
```

## 验证
```
# for i in `seq 1 65535`;do mkdir /sys/fs/cgroup/memory/test/test-${i}; done  
# cat /proc/cgroups |grep memory  
memory  11      65535   1
```
把系统 cgroup memory 填到 65535 个。
```
# for i in `seq 1 100`;do rmdir /sys/fs/cgroup/memory/test/test-${i} 2>/dev/null 1>&2; done   
# mkdir /sys/fs/cgroup/memory/stress/  
# for i in `seq 1 100`;do mkdir /sys/fs/cgroup/memory/test/test-${i}; done   
mkdir: cannot create directory ‘/sys/fs/cgroup/memory/test/test-100’: No space left on device  
# for i in `seq 1 100`;do rmdir /sys/fs/cgroup/memory/test/test-${i}; done  
# cat /proc/cgroups |grep memory  
memory  11      65436   1  
```
在写入第 100 个的时候提示无法写入，证明写入了 99 个。
在测试环境会频繁创建和删除pod，在cgroup memory泄露的时候，删除pod并不会释放空间，达到上限后会报no space left on device 。

## 解决
#### 1.修改kubernetes代码。把1.9中删除的判断条件加上去。
#### 2.关闭kernel的CONFIG_MEMCG_KMEM， 重新编译内核来解决。
