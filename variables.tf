variable "name" {
  type        = "string"
  default     = "elasticsearch"
  description = "Name you want to give to your instances"
}

variable "environment" {
  type        = "string"
  description = "The name of the environment (production, staging , development)."
}

variable "project" {
  type        = "string"
  description = "The name of the project"
}

variable "cluster_size" {
  default     = 3
  description = "How many Elasticsearch nodes to deploy."
}

variable "logstash_enabled" {
  default     = false
  description = "Whether to enable Logstash listeners."
}

variable "kibana_enabled" {
  default     = false
  description = "Whether to enable Kibana listeners."
}

variable "elasticsearch_port" {
  default     = 9200
  description = "Elasticsearch port."
}

variable "elasticsearch_java_port" {
  default     = 9300
  description = "Elasticsearch JAVA API port."
}

variable "logstash_port" {
  default     = 9600
  description = "Logstash port."
}

variable "kibana_port" {
  default     = 5601
  description = "Kibana port."
}

variable "ami" {
  type        = "string"
  description = "AMI to be used for the Elasticsearch nodes."
}

variable "instance_type" {
  type        = "string"
  default     = "t2.small"
  description = "The instance type to launch for the Elasticsearch nodes."
}

variable "key_name" {
  type        = "string"
  description = "ID of the SSH key to use for the Elasticsearch nodes."
}

variable "subnet_ids" {
  type        = "list"
  description = "Subnet IDs where the cluster will be deployed."
}

variable "termination_protection" {
  default     = true
  description = "Whether to enable termination protection on the Elasticsearch nodes."
}

variable "db_vl_type" {
  type        = "string"
  default     = "gp2"
  description = "Type of the Elasticsearch data EBS volume."
}

variable "db_vl_iops" {
  default     = 0
  description = "The amount of provisioned IOPS. This is only valid for db_vl_type of io1, and must be specified if using"
}

variable "db_vl_encrypted" {
  type        = "string"
  default     = "false"
  description = "Enables EBS encryption on the volume."
}

variable "db_vl_size" {
  default     = 100
  description = "Size in GB of the Elasticsearch data EBS volume."
}

variable "db_vl_name" {
  type        = "string"
  default     = "/dev/xvdg"
  description = "Volume device name of the Elasticsearch data EBS volume."
}

variable "db_vl_delete_on_termination" {
  type        = "string"
  default     = "true"
  description = "Delete the EBS volume when we terminate the instance."
}

variable "elb_internal" {
  type        = "string"
  default     = true
  description = "Whether the ELB should be internal only (not-public)."
}

variable "elb_ingress_sgs" {
  type        = "list"
  description = "List of Security Groups which need access to the cluster."
}

variable "sg_all_id" {
  type        = "string"
  description = "ID of the base security group."
}

variable "vpc_id" {
  type        = "string"
  description = "VPC ID where the proxies will be deployed."
}

variable "snapshot_s3_bucket_arn" {
  type        = "string"
  default     = ""
  description = "The S3 bucket ARN where the ES snapshots will be stored, this is just to give the proper permissions to the EC2 instance profiles."
}

variable "es_data_dir" {
  type        = "string"
  default     = "/usr/share/elasticsearch/data/"
  description = "The directory where to mount the external volume, so this will be the directory where Elasticsearch will store the data."
}
