# kafka-rest部署手册

#### 下载confluent
从下列连接下载confluent到任意目录，本例以下载到/home/downdoad目录为例
https://www.confluent.io/download/plans

```
# cd /home/download/
# tar -zxvf confluent-community-5.3.1-2.12.tar.gz 
# cd confluent-5.3.1/
# cat >> etc/kafka-rest/kafka-rest.properties <<EOF
id=kafka-rest-test-server
zookeeper.connect=192.168.3.145:2181,192.168.3.152:2181,192.168.3.166:2181
bootstrap.servers=PLAINTEXT://192.168.3.145:9092,PLAINTEXT://192.168.3.152:9092,PLAINTEXT://192.168.3.166:9092
EOF
# nohup ./bin/kafka-rest-start etc/kafka-rest/kafka-rest.properties &
```
