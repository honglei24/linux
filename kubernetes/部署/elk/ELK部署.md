# ELK部署手册

## 环境准备
elasticsearch是基于java开发的，所以需要安装java环境， 这里只是演示，生产环境建议使用Oracle的JDK
```
# yum install -y java-1.8.0-openjdk
# java -version
openjdk version "1.8.0_222"
OpenJDK Runtime Environment (build 1.8.0_222-b10)
OpenJDK 64-Bit Server VM (build 25.222-b10, mixed mode)
```

添加elk用户
```
# groupadd elk
# useradd -g elk elk
# id elk
uid=1001(elk) gid=1002(elk) groups=1002(elk)
# chown -R elk.elk /home/elk/
```

修改limits.conf, 添加一下内容
```
# vi /etc/security/limits.conf
* soft nproc 65536
* hard nproc 131072
* soft nofile 65536
* hard nofile 131072
```

如果修改没有生效，需要重新登录下
```
# ulimit -n
65536
```

修改内核参数vm.max_map_count
```
echo vm.max_map_count=262144 >>/etc/sysctl.conf
sysctl -p
```

## 安装Elasticsearch
```
# su - elk
$ wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.4.0-linux-x86_64.tar.gz
$ tar zxvf kibana-7.4.0-linux-x86_64.tar.gz 
$ cd elasticsearch-7.4.0/
$ vi config/
如果有必要，需要修改network.host和discovery.seed_hosts
network.host: 0.0.0.0
discovery.seed_hosts: ["127.0.0.1", "[::1]", "192.168.3.166"]
$ ./bin/elasticsearch -d
$ less logs/elasticsearch.log 
```
通过logs/elasticsearch.log 查看启动日志。

启动成功会监听9200端口
```
$ netstat -antp | grep 9200

```


## 安装Kibana
```
$ wget https://artifacts.elastic.co/downloads/kibana/kibana-7.4.0-linux-x86_64.tar.gz
$ tar zxvf kibana-7.4.0-linux-x86_64.tar.gz
$ cd kibana-7.4.0-linux-x86_64/
$ ls config/
kibana.yml
```

修改配置文件的内容，elasticsearch.hosts设置为elasticsearch节点信息。
```
$ vi config/kibana.yml
server.port: 5601
server.host: 0.0.0.0
elasticsearch.hosts: ["http://192.168.3.166:9200"]
```

启动服务
```
$ nohup ./bin/kibana &>kibana.log &
```

启动成功了，可以通过5601端口访问


## 安装Logstash
```
$ wget https://artifacts.elastic.co/downloads/logstash/logstash-7.4.0.tar.gz
$ tar zxvf logstash-7.4.0.tar.gz 
$ cd logstash-7.4.0/
$ vi config/logstash.conf
input {
  kafka {
    bootstrap_servers => "192.168.3.145:9092,192.168.3.152:9092,192.168.3.166:9092"
    topics => ["test"]
    group_id => "groupA"
    codec => "json"
  }
}
 
output {
    if "app" in [tags] {
        elasticsearch {
            hosts => "localhost:9200"
            index => "logstash-application-%{+YYYY.MM.dd}"
            manage_template => false
        }
    }
    if "sys" in [tags] {
        elasticsearch {
            hosts => "localhost:9200"
            index => "logstash-syslog-%{+YYYY.MM.dd}"
            manage_template => false
        }
    }
    if "kube" in [tags] {
        elasticsearch {
            hosts => "localhost:9200"
            index => "logstash-kube-%{+YYYY.MM.dd}"
            manage_template => false
        }
    }
    stdout {
        codec => rubydebug
    }
}
```

- input: 从5044端口接收日志
- output: 将过滤的日志存储到es中，并建立索引
- stdout: 将接收的日志输出到控制台，有助于调试, 生产环境可以关闭该配置
- logstash可以结合kafka来实现横向扩展，指定相同的group_id即可

启动logstash服务
```
bin/logstash -f config/logstash.conf 
```
