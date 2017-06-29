module "elk_instances" {
  source                 = "github.com/skyscrapers/terraform-instances//instance?ref=1.1.0"
  project                = "${var.project}"
  environment            = "${var.environment}"
  name                   = "${var.name}"
  instance_count         = "${var.cluster_size}"
  termination_protection = "${var.termination_protection}"
  key_name               = "${var.key_name}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnets                = "${var.subnet_ids}"
  sgs                    = ["${aws_security_group.elk_sg.id}", "${var.sg_all_id}"]
  user_data              = "${data.template_cloudinit_config.instances_userdata.*.rendered}"
  ebs_block_devices      = ["${zipmap("${var.ebs_block_device_properties}", list("${var.db_vl_name}", "${var.db_vl_type}", "${var.db_vl_size}", "${var.db_vl_iops}", "${var.db_vl_delete_on_termination}", "${var.db_vl_encrypted}"))}"]
}

variable "ebs_block_device_properties" {
  default = ["device_name", "volume_type", "volume_size", "iops", "delete_on_termination", "encrypted"]
}

module "elk_userdata" {
  source              = "github.com/skyscrapers/terraform-skyscrapers//puppet-userdata?ref=1.0.1"
  amount_of_instances = "${var.cluster_size}"
  customer            = "${var.project}"
  environment         = "${var.environment}"
  function            = "${var.name}"
}

data "template_cloudinit_config" "instances_userdata" {
  count         = "${var.cluster_size}"
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "package_update: true"
  }

  part {
    content_type = "text/cloud-config"

    content = <<EOF
packages:
  - awscli
EOF
  }

  # Wait for the EBS volume to become ready
  # And format and mount the drive
  part {
    content_type = "text/x-shellscript"

    content = <<EOF
#!/bin/bash
aws --region $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//') ec2 wait volume-in-use --filters Name=attachment.instance-id,Values=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) Name=attachment.device,Values=${var.db_vl_name}
mkfs.ext4 ${var.db_vl_name}
mkdir -p ${var.es_data_dir}
mount ${var.db_vl_name} ${var.es_data_dir}
EOF
  }

  # Bootstrap puppet
  part {
    content_type = "text/x-shellscript"
    content      = "${module.elk_userdata.user_datas[count.index]}"
  }
}

variable "elb_listener_keys" {
  default = ["instance_port", "instance_protocol", "lb_port", "lb_protocol"]
}

resource "aws_elb" "elk_elb" {
  name                      = "${var.name}-${var.project}-${var.environment}"
  count                     = "${var.cluster_size == "0" ? 0 : var.cluster_size}"
  cross_zone_load_balancing = true
  connection_draining       = false
  security_groups           = ["${aws_security_group.elk_elb_sg.id}"]
  internal                  = "${var.elb_internal}"
  subnets                   = ["${var.subnet_ids}"]
  instances                 = ["${module.elk_instances.instance_ids}"]

  # This ugly-and-unreadable piece of code is to dynamically add listeners to the ELB depending on enabled features (var.logstash_enabled and var.kibana_enabled)
  # There will always be two fix listeners (the first two)
  # and depending on var.logstash_enabled and var.kibana_enabled, the corresponding listeners for logstash and kibana will be added or not
  listener = "${concat(
    list(
      zipmap("${var.elb_listener_keys}", list("${var.elasticsearch_port}", "http", "${var.elasticsearch_port}", "http")),
      zipmap("${var.elb_listener_keys}", list("${var.elasticsearch_java_port}", "tcp", "${var.elasticsearch_java_port}", "tcp"))
    ),
    slice(list(zipmap("${var.elb_listener_keys}", list("${var.logstash_port}", "http", "${var.logstash_port}", "http"))), 0, var.logstash_enabled ? 1 : 0),
    slice(list(zipmap("${var.elb_listener_keys}", list("${var.kibana_port}", "http", "${var.kibana_port}", "http"))), 0, var.kibana_enabled ? 1 : 0),
  )}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 4
    timeout             = 10
    target              = "HTTP:${var.elasticsearch_port}/"
    interval            = 12
  }

  tags {
    Name        = "${var.project}-${var.environment}-${var.name}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}
