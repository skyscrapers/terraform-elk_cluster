module "elk_instances" {
  source                 = "github.com/skyscrapers/terraform-instances//instance?ref=c9990f962bdfb06a7932b75b1162e545fa0ed64a"
  project                = "${var.project}"
  environment            = "${var.environment}"
  name                   = "${var.name}"
  instance_count         = "${var.cluster_size}"
  termination_protection = "${var.termination_protection}"
  key_name               = "${var.key_name}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnets                = "${var.subnet_ids}"
  sgs                    = [ "${aws_security_group.elk_sg.id}", "${var.sg_all_id}" ]
  user_data              = [ "${module.elk_userdata.user_datas}" ]
}

module "elk_userdata" {
  source              = "github.com/skyscrapers/terraform-skyscrapers//puppet-userdata?ref=1.0.1"
  amount_of_instances = "${var.cluster_size}"
  customer            = "${var.project}"
  environment         = "${var.environment}"
  function            = "${var.name}"
}

resource "aws_ebs_volume" "elk_volume" {
  count             = "${var.cluster_size}"
  availability_zone = "${module.elk_instances.instance_azs[count.index]}"
  size              = "${var.db_vl_size}"
  type              = "${var.db_vl_type}"
}

resource "aws_volume_attachment" "elk_ebs_attach" {
  count       = "${var.cluster_size}"
  device_name = "${var.db_vl_name}"
  volume_id   = "${element(aws_ebs_volume.elk_volume.*.id, count.index)}"
  instance_id = "${module.elk_instances.instance_ids[count.index]}"
}

resource "aws_elb" "elk_elb" {
  name                      = "${var.name}-${var.project}-${var.environment}"
  cross_zone_load_balancing = true
  connection_draining       = false
  security_groups           = ["${aws_security_group.elk_elb_sg.id}"]
  internal                  = "${var.elb_internal}"
  subnets                   = ["${var.subnet_ids}"]

  listener = [
    {
      instance_port     = "${var.elasticsearch_port}"
      instance_protocol = "http"
      lb_port           = "${var.elasticsearch_port}"
      lb_protocol       = "http"
    },
    {
      instance_port     = "${var.elasticsearch_java_port}"
      instance_protocol = "tcp"
      lb_port           = "${var.elasticsearch_java_port}"
      lb_protocol       = "tcp"
    },
  ]

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
