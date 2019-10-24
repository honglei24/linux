// http_sample
package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

func hello(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "hello\n")
}

func log_kafka_rest(w http.ResponseWriter, req *http.Request) {
	client := &http.Client{}
	//生成要访问的url
	s, _ := ioutil.ReadAll(req.Body)
	tmp := fmt.Sprintf("{\"records\":[{\"value\":%s}]}\n", s)

	host := os.Getenv("KAFKA_REST_HOST")
	port := os.Getenv("KAFKA_REST_PORT")
	topic := os.Getenv("KAFKA_REST_TOPIC")
	//url := "http://192.168.3.166:8082/topics/filebeat"
	url := fmt.Sprintf("http://%s:%s/topics/%s", host, port, topic)

	fmt.Println(url)
	//提交请求
	reqest, err := http.NewRequest("POST", url, strings.NewReader(string(tmp)))
	if err != nil {
		fmt.Fprintf(w, "create request FAILED!\n", tmp)
		panic(err)
	}
	//增加header选项
	reqest.Header.Add("Content-Type", "application/vnd.kafka.json.v2+json")

	//处理返回结果
	response, _ := client.Do(reqest)
	if response.StatusCode != 200 {
		fmt.Fprintf(w, "sent message :%s FAILED!\n", tmp)
	}
	defer response.Body.Close()
}

func main() {

	http.HandleFunc("/hello", hello)
	http.HandleFunc("/log_kafka_rest", log_kafka_rest)

	http.ListenAndServe(":8080", nil)
}
