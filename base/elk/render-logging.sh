#!/bin/sh
# 
# We are using the elastic.co helm charts to generate our deployment.
# Run this script to update to the latest/greatest and then check it in.
#

helm repo add elastic https://helm.elastic.co
helm repo update
kubectl config set-context --current --namespace=elk

helm template elasticsearch-logging elastic/elasticsearch -f elasticsearch-values.yml > elasticsearch/elasticsearch.yml
helm template kibana elastic/kibana > kibana/kibana.yml
helm template logstash elastic/logstash -f logstash-values.yml > logstash/logstash.yml

#kubectl config set-context --current --namespace=kube-system
#helm template filebeat elastic/filebeat -f filebeat-values.yml --namespace kube-system > filebeat/filebeat.yml
helm template filebeat elastic/filebeat -f filebeat-values.yml > filebeat/filebeat.yml

