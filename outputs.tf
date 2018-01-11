output "sg_id" {
  value = "${aws_security_group.elk_sg.id}"
}

output "sg_elb_id" {
  value = "${aws_security_group.elk_elb_sg.0.id}"
}

output "elb_id" {
  value = "${aws_elb.elk_elb.0.id}"
}

output "elb_dns_name" {
  value = "${aws_elb.elk_elb.0.dns_name}"
}

output "elb_zone_id" {
  value = "${aws_elb.elk_elb.0.zone_id}"
}
