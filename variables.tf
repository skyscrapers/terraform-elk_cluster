variable "name" {
  type    = "string"
  default = "elasticsearch"
}

variable "environment" {
  type = "string"
}

variable "project" {
  type = "string"
}

variable "cluster_size" {
  default = 3
}

variable "logstash_enabled" {
  default = false
}

variable "kibana_enabled" {
  default = false
}

variable "elasticsearch_port" {
  default = 9200
}

variable "elasticsearch_java_port" {
  default = 9300
}

variable "logstash_port" {
  default = 9600
}

variable "kibana_port" {
  default = 5601
}

variable "ami" {
  type = "string"
}

variable "instance_type" {
  type    = "string"
  default = "t2.small"
}

variable "key_name" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "termination_protection" {
  default = true
}

variable "db_vl_type" {
  type    = "string"
  default = "gp2"
}

variable "db_vl_size" {
  default = 100
}

variable "db_vl_name" {
  type    = "string"
  default = "/dev/xvdg"
}

variable "elb_internal" {
  type    = "string"
  default = true
}

variable "elb_ingress_sgs" {
  type = "list"
}

variable "sg_all_id" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}
