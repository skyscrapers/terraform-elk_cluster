resource "aws_security_group" "elk_sg" {
  name        = "sg_${var.name}_${var.project}_${var.environment}"
  description = "Security group that is needed for the ELK cluster"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "sg_${var.name}_${var.project}_${var.environment}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

resource "aws_security_group" "elk_elb_sg" {
  name        = "sg_elb_${var.name}_${var.project}_${var.environment}"
  description = "Security group that is needed for the ELK cluster ELB"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "sg_elb_${var.name}_${var.project}_${var.environment}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

## INSTANCES

resource "aws_security_group_rule" "instance_ingress_cluster" {
  type              = "ingress"
  from_port         = "${var.elasticsearch_java_port}"
  to_port           = "${var.elasticsearch_java_port}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.elk_sg.id}"
  self              = true
}

resource "aws_security_group_rule" "instance_egress_cluster" {
  type              = "egress"
  from_port         = "${var.elasticsearch_java_port}"
  to_port           = "${var.elasticsearch_java_port}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.elk_sg.id}"
  self              = true
}

resource "aws_security_group_rule" "instance_ingress_es_from_elb" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.elasticsearch_port}"
  to_port                  = "${var.elasticsearch_port}"
  security_group_id        = "${aws_security_group.elk_sg.id}"
  source_security_group_id = "${aws_security_group.elk_elb_sg.id}"
}

resource "aws_security_group_rule" "instance_ingress_es_java_from_elb" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.elasticsearch_java_port}"
  to_port                  = "${var.elasticsearch_java_port}"
  security_group_id        = "${aws_security_group.elk_sg.id}"
  source_security_group_id = "${aws_security_group.elk_elb_sg.id}"
}

resource "aws_security_group_rule" "instance_ingress_logstash_from_elb" {
  count                    = "${var.logstash_enabled ? 1 : 0}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.logstash_port}"
  to_port                  = "${var.logstash_port}"
  security_group_id        = "${aws_security_group.elk_sg.id}"
  source_security_group_id = "${aws_security_group.elk_elb_sg.id}"
}

resource "aws_security_group_rule" "instance_ingress_kibana_from_elb" {
  count                    = "${var.kibana_enabled ? 1 : 0}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.kibana_port}"
  to_port                  = "${var.kibana_port}"
  security_group_id        = "${aws_security_group.elk_sg.id}"
  source_security_group_id = "${aws_security_group.elk_elb_sg.id}"
}

## ELB

resource "aws_security_group_rule" "elb_ingress_es_from_outside" {
  count                    = "${length(var.elb_es_ingress_sgs)}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.elasticsearch_port}"
  to_port                  = "${var.elasticsearch_port}"
  security_group_id        = "${aws_security_group.elk_elb_sg.id}"
  source_security_group_id = "${element(var.elb_es_ingress_sgs, count.index)}"
}

resource "aws_security_group_rule" "elb_egress_es_to_instance" {
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.elasticsearch_port}"
  to_port                  = "${var.elasticsearch_port}"
  security_group_id        = "${aws_security_group.elk_elb_sg.id}"
  source_security_group_id = "${aws_security_group.elk_sg.id}"
}

resource "aws_security_group_rule" "elb_ingress_es-java_from_outside" {
  count                    = "${length(var.elb_es_ingress_sgs)}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.elasticsearch_java_port}"
  to_port                  = "${var.elasticsearch_java_port}"
  security_group_id        = "${aws_security_group.elk_elb_sg.id}"
  source_security_group_id = "${element(var.elb_es_ingress_sgs, count.index)}"
}

resource "aws_security_group_rule" "elb_egress_es-java_to_instance" {
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.elasticsearch_java_port}"
  to_port                  = "${var.elasticsearch_java_port}"
  security_group_id        = "${aws_security_group.elk_elb_sg.id}"
  source_security_group_id = "${aws_security_group.elk_sg.id}"
}

resource "aws_security_group_rule" "elb_ingress_logstash_from_outside" {
  count                    = "${var.logstash_enabled ? length(var.elb_logstash_ingress_sgs) : 0}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.logstash_port}"
  to_port                  = "${var.logstash_port}"
  security_group_id        = "${aws_security_group.elk_elb_sg.id}"
  source_security_group_id = "${element(var.elb_logstash_ingress_sgs, count.index)}"
}

resource "aws_security_group_rule" "elb_egress_logstash_to_instance" {
  count                    = "${var.logstash_enabled ? 1 : 0}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.logstash_port}"
  to_port                  = "${var.logstash_port}"
  security_group_id        = "${aws_security_group.elk_elb_sg.id}"
  source_security_group_id = "${aws_security_group.elk_sg.id}"
}

resource "aws_security_group_rule" "elb_ingress_kibana_from_outside" {
  count                    = "${var.kibana_enabled ? length(var.elb_kibana_ingress_sgs) : 0}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.kibana_port}"
  to_port                  = "${var.kibana_port}"
  security_group_id        = "${aws_security_group.elk_elb_sg.id}"
  source_security_group_id = "${element(var.elb_kibana_ingress_sgs, count.index)}"
}

resource "aws_security_group_rule" "elb_egress_kibana_to_instance" {
  count                    = "${var.kibana_enabled ? 1 : 0}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.kibana_port}"
  to_port                  = "${var.kibana_port}"
  security_group_id        = "${aws_security_group.elk_elb_sg.id}"
  source_security_group_id = "${aws_security_group.elk_sg.id}"
}
