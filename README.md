# terraform-elk_cluster

Terraform module to setup all resources needed for an Elasticsearch cluster.

## Available variables

*   \[`project`\]: String(required): The name of the project.
*   \[`customer`\]: String(optional): The name of the customer. 
*   \[`environment`\]: String(required): The name of the environment (production, staging , development).
*   \[`elb_es_ingress_sgs`\]: List(required): List of Security Groups which need access to the Elasticsearch port of the cluster.
*   \[`vpc_id`\]: String(required): VPC ID where the proxies will be deployed.
*   \[`subnet_ids`\]: List(required): Subnet IDs where the cluster will be deployed.
*   \[`sg_all_id`\]: String(required): ID of the base security group.
*   \[`ami`\]: String(required): AMI to be used for the Elasticsearch nodes.
*   \[`key_name`\]: String(required): ID of the SSH key to use for the Elasticsearch nodes.
*   \[`name`\]: String(optional, default "elasticsearch"): Name to use for the ELK setup.
*   \[`cluster_size`\]: Number(optional, default 3): How many Elasticsearch nodes to deploy.
*   \[`logstash_enabled`\]: Bool(optional, default false): Whether to enable Logstash listeners.
*   \[`kibana_enabled`\]: Bool(optional, default false): Whether to enable Kibana listeners.
*   \[`elasticsearch_port`\]: Number(optional, default 9200): Elasticsearch port.
*   \[`elasticsearch_java_port`\]: Number(optional, default 9300): Elasticsearch JAVA API port.
*   \[`logstash_port`\]: Number(optional, default 9600): Logstash port.
*   \[`kibana_port`\]: Number(optional, default 5601): Kibana port.
*   \[`elb_kibana_ingress_sgs`\]: List(optional): List of Security Groups which need access to the Kibana port of the cluster.
*   \[`elb_logstash_ingress_sgs`\]: List(optional): List of Security Groups which need access to the Logstash port of the cluster.
*   \[`instance_type`\]: String(optional, default "t2.small"): The instance type to launch for the Elasticsearch nodes.
*   \[`termination_protection`\]: Bool(optional, default true): Whether to enable termination protection on the Elasticsearch nodes.
*   \[`db_vl_type`\]: String(optional, default "gp2"): Type of the Elasticsearch data EBS volume.
*   \[`db_vl_iops`\]: String(optional, default ""): The amount of provisioned IOPS. This is only valid for db_vl_type of "io1", and must be specified if using that type
*   \[`db_vl_size`\]: Number(optional, default 100): Size in GB of the Elasticsearch data EBS volume.
*   \[`db_vl_name`\]: String(optional, default "/dev/xvdg"): Volume device name of the Elasticsearch data EBS volume.
*   \[`db_vl_encrypted`\]: String(optional, default "false"): Enables EBS encryption on the volume.
*   \[`db_vl_delete_on_termination`\]: String(optional, default "true"): Delete the EBS volume when we terminate the instance.
*   \[`elb_internal`\]: Bool(optional, default true): Whether the ELB should be internal only (not-public).
*   \[`snapshot_s3_bucket_arn`\]: String(optional, default ""): The S3 bucket ARN where the ES snapshots will be stored, this is just to give the proper permissions to the EC2 instance profiles.
*   \[`es_data_dir`\]: String(optional, default "/usr/share/elasticsearch/data/"): The directory where to mount the external volume, so this will be the directory where Elasticsearch will store the data.

## Output

*   \[`sg_id`\]: String: ID of the Elasticsearch instances Security Group.
*   \[`sg_elb_id`\]: String: ID of the cluster's ELB Security Group.
*   \[`elb_id`\]: String: ID of the cluster's ELB.
*   \[`elb_dns_name`\]: String: DNS name of the cluster's ELB.
*   \[`elb_zone_id`\]: String: Zone ID of the cluster's ELB.

## Example

```terraform
module "elk_cluster" {
  source              = "github.com/skyscrapers/terraform-elk_cluster?ref=1.0.0"
  project             = "${var.project}"
  environment         = "${var.environment}"
  cluster_size        = 3
  logstash_enabled    = true
  kibana_enabled      = true
  ami                 = "ami-6c101b0a"
  instance_type       = "t2.small"
  key_name            = "mykey"
  vpc_id              = "${module.vpc.vpc_id}"
  subnet_ids          = "${module.vpc.private_db_subnets}"
  sg_all_id           = "${module.general_security_groups.sg_all_id}"
  elb_es_ingress_sgs  = ["${module.app.sg_id}"]
}
```
