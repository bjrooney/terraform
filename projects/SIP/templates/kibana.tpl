#!/bin/bash -v

set -e
set -u


rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
setsebool -P httpd_can_network_connect 1

echo '[elasticsearch-2.x]
name=Elasticsearch repository for 2.x packages
baseurl=http://packages.elastic.co/elasticsearch/2.x/centos
gpgcheck=0
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
' | tee /etc/yum.repos.d/elasticsearch.repo

yum -y install elasticsearch

systemctl enable elasticsearch.service
systemctl daemon-reload
systemctl start elasticsearch.service


echo '[kibana-4.4]
name=Kibana repository for 4.4.x packages
baseurl=http://packages.elastic.co/kibana/4.4/centos
gpgcheck=0
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
' | tee /etc/yum.repos.d/kibana.repo



yum -y install kibana

systemctl stop firewalld
firewall-offline-cmd    --add-port=5601/tcp
systemctl start firewalld


systemctl enable kibana 
systemctl daemon-reload
systemctl start kibana.service

echo '
server {
    listen 80;

    server_name http://kibana."${var.domain}"/;


    location / {
    	client_max_body_size 1000m;
        chunked_transfer_encoding off;
        proxy_set_header    Host              $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_buffering     off;
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;      
    }
}
' | tee  /etc/nginx/conf.d/kibana.conf
systemctl enable nginx
systemctl restart nginx.service

echo '[logstash-2.2]
name=logstash repository for 2.2 packages
baseurl=http://packages.elasticsearch.org/logstash/2.2/centos
gpgcheck=0
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
' | tee /etc/yum.repos.d/logstash.repo

yum -y install logstash

systemctl enable logstash
systemctl daemon-reload
cd /root

curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.1.0.zip

curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json



