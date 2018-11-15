开启聚合层 
修改apiserver配置文件，加入如下启动参数来启用aggregation layer：

--requestheader-client-ca-file=/etc/kubernetes/ssl/ca.pem
--requestheader-allowed-names=kube-apiserver
--requestheader-extra-headers-prefix=X-Remote-Extra-
--requestheader-group-headers=X-Remote-Group
--requestheader-username-headers=X-Remote-User
--------------------- 
部署 metrics-server
git clone https://github.com/kubernetes-incubator/metrics-server
cd metrics-server
#########证书访问
Vi deploy/1.8+/metrics-server-deployment.yaml 
- name: metrics-server
        image: k8s.gcr.io/metrics-server-amd64:v0.3.1
        imagePullPolicy: Always
        args: ["--kubelet-insecure-tls"] ##添加行
        volumeMounts:
        - name: tmp-dir
          mountPath: /tmp
#######

kubectl create -f deploy/1.8+/


稍后就可以看到 metrics-server 运行起来：

kubectl -n kube-system get pods -l k8s-app=metrics-server

备注： 
	1. 假如gcr.io的镜像访问不到可以将metrics-server-deployment.yaml中的镜像替换为：cherryhyx/metrics-server:v0.3.1
	2. 有时无法访问到节点名,如访问node1,master等地址.需要添加/etc/hosts内容到pod里


可通过命令行访问:kubectl get –-raw "/apis/metrics.k8s.io/v1beta1/nodes"

