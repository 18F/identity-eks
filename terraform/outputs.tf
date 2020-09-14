#
# Outputs
#

locals {
#   logstash_config = <<EOF
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: logstash-configmap
#   namespace: elk
# data:
#   logstash.yml: |
#     http.host: "0.0.0.0"
#     path.config: /usr/share/logstash/pipeline
#   logstash.conf: |
#     # all input will come from filebeat, no local logs
#     input {
#       beats {
#         port => 5044
#       }
#     }
#     filter {
#     }
#     output {
#       amazon_es {
#         index => "logstash-%%{[@metadata][beat]}-%%{+YYYY.MM.dd}"
#         hosts => [ "${aws_elasticsearch_domain.es.endpoint}" ]
#         region => "${var.region}"
#       }
#     }
# EOF

}

# output "logstash_config" {
#   value = local.logstash_config
# }
