# kafka集群部署手册

#### 服务器信息
服务器名 | IP | 用途 | 
---|---|---|
test-work01 |192.169.3.145 | kafka节点1，zookeeper节点 | 
test-work02 |192.169.3.152 | kafka节点2，zookeeper节点 | 
test-work03 |192.169.3.166 | kafka节点3，zookeeper节点 | 

#### 软件版本信息
软件名 | 版本 |
---|---|
OS |CentOS 7 | 
kafka |2.3.0 | 

#### zookeeper部署
1. 下载ZooKeeper&基础准备
下载ZooKeeper
官方镜像选择：https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/
```
cd /home/download
wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
创建ZooKeeper相关目录
#创建应用目录
mkdir /usr/zookeeper

#创建数据目录
mkdir /zookeeper
mkdir /zookeeper/data
mkdir /zookeeper/logs
解压到指定目录
tar -zvxf zookeeper-3.4.14.tar.gz -C /usr/zookeeper
配置环境变量
#修改环境变量文件
vi /etc/profile

#增加以下内容
export ZOOKEEPER_HOME=/usr/zookeeper/zookeeper-3.4.14
export PATH=$ZOOKEEPER_HOME/bin:$PATH

#使环境变量生效
source /etc/profile

#查看配置结果
echo $ZOOKEEPER_HOME
既然已配置环境变量，为了方便访问ZooKeeper目录
后续通过$ZOOKEEPER_HOME代替/usr/zookeeper/zookeeper-3.4.14
```

2. 配置ZooKeeper
ZooKeeper基础配置
```
#进入ZooKeeper配置目录
cd $ZOOKEEPER_HOME/conf

#新建配置文件
vi zoo.cfg

#写入以下内容并保存

tickTime=2000
initLimit=10
syncLimit=5
dataDir=/zookeeper/data
dataLogDir=/zookeeper/logs
clientPort=2181
server.1=192.168.3.145:2888:3888
server.2=192.168.3.152:2888:3888
server.3=192.168.3.166:2888:3888
配置节点标识
zk01：

echo "1" > /zookeeper/data/myid
zk02：

echo "2" > /zookeeper/data/myid
zk03：

echo "3" > /zookeeper/data/myid
防火墙配置
#开放端口
firewall-cmd --add-port=2181/tcp --permanent
firewall-cmd --add-port=2888/tcp --permanent
firewall-cmd --add-port=3888/tcp --permanent

#重新加载防火墙配置
firewall-cmd --reload
```

3. 启动ZooKeeper
```
#进入ZooKeeper bin目录
cd $ZOOKEEPER_HOME/bin

#启动
sh zkServer.sh start
出现以下字样表示启动成功：

ZooKeeper JMX enabled by default
Using config: /usr/zookeeper/zookeeper-3.4.14/bin/../conf/zoo.cfg
Starting zookeeper … STARTED
```

4. 查看节点状态
```
sh $ZOOKEEPER_HOME/bin/zkServer.sh status

#状态信息
ZooKeeper JMX enabled by default
Using config: /usr/zookeeper/zookeeper-3.4.14/bin/../conf/zoo.cfg
Mode: follower

#如果为领导者节点则Mode:leader

```

5. 客户端连接测试
这里随机选其中一个节点作为客户端连接其他节点即可
```
#指定Server进行连接
sh $ZOOKEEPER_HOME/bin/zkCli.sh -server 192.168.3.166:2181

#正常连接后会进入ZooKeeper命令行，显示如下：
[zk: 192.168.3.166:2181(CONNECTED) 0]
输入命令测试：

#查看ZooKeeper根
[zk: 192.168.3.166:2181(CONNECTED) 0] ls /
[zookeeper]
```

#### kafka集群部署
1. 应用&数据目录
```
#创建应用目录
mkdir /usr/kafka

#创建Kafka数据目录
mkdir /kafka
mkdir /kafka/logs
chmod 777 -R /kafka
```

2. 下载&解压
Kafka官方下载地址：https://kafka.apache.org/downloads

```
#创建并进入下载目录
mkdir /home/downloads
cd /home/downloads

#下载安装包
wget http://mirrors.tuna.tsinghua.edu.cn/apache/kafka/2.3.0/kafka_2.12-2.3.0.tgz 

#解压到应用目录
tar -zvxf kafka_2.12-2.3.0.tgz -C /usr/kafka
```

3. Kafka节点配置
```
#进入应用目录
cd /usr/kafka/kafka_2.12-2.3.0/

#修改配置文件
vi config/server.properties
通用配置
配置日志目录、指定ZooKeeper服务器

# A comma separated list of directories under which to store log files
log.dirs=/kafka/logs

# root directory for all kafka znodes.
zookeeper.connect=192.168.3.145:2181,192.168.3.152:2181,192.168.3.166:2181
分节点配置
test-work01
broker.id=0

#listeners=PLAINTEXT://:9092
listeners=PLAINTEXT://192.168.3.145:9092

test-work02
broker.id=1

#listeners=PLAINTEXT://:9092
listeners=PLAINTEXT://192.168.3.152:9092

test-work03
broker.id=2

#listeners=PLAINTEXT://:9092
listeners=PLAINTEXT://192.168.3.166:9092
```

4. 防火墙配置
```
#开放端口
firewall-cmd --add-port=9092/tcp --permanent

#重新加载防火墙配置
firewall-cmd --reload

也可以之间关闭firewall-cmd服务
```

5. 启动Kafka
```
#进入kafka根目录

cd /usr/kafka/kafka_2.12-2.3.0/

#启动

/bin/kafka-server-start.sh config/server.properties &

```


#### test-work测试
1. 创建Topic
在kafka01(Broker)上创建测试Tpoic：test，这里我们指定了3个副本. 1个分区
```
bin/kafka-topics.sh --create --bootstrap-server 192.168.3.145:9092 --replication-factor 3 --partitions 1 --topic test
```
Topic在kafka01上创建后也会同步到集群中另外两个Broker：kafka02. kafka03

2. 查看Topic
我们可以通过命令列出指定Broker的
```
bin/kafka-topics.sh --list --bootstrap-server 192.168.3.152:9092
```
3. 发送消息
这里我们向Broker(id=0)的Topic=test发送消息
```
bin/kafka-console-producer.sh --broker-list  192.168.3.145:9092  --topic test

#消息内容
> test by honglei
```

4. 消费消息
在test-work02上消费Broker03的消息
```
bin/kafka-console-consumer.sh --bootstrap-server 192.168.3.166:9092 --topic test --from-beginning
```

在test-work03上消费Broker02的消息
```
bin/kafka-console-consumer.sh --bootstrap-server 192.168.3.152:9092 --topic test --from-beginning
```
然后均能收到消息

test by honglei
这是因为这两个消费消息的命令是建立了两个不同的Consumer
如果我们启动Consumer指定Consumer Group Id就可以作为一个消费组协同工，1个消息同时只会被一个Consumer消费到

```
bin/kafka-console-consumer.sh --bootstrap-server 192.168.3.166:9092 --topic test --from-beginning --group groupA
bin/kafka-console-consumer.sh --bootstrap-server 192.168.3.152:9092 --topic test --from-beginning --group groupA
```