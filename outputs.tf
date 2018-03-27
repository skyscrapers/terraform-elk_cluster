output "sg_id" {
  value = "${aws_security_group.elk_sg.id}"
}

output "sg_elb_id" {
  value = "${join("", aws_security_group.elk_elb_sg.*.id)}"
}

output "elb_id" {
  value = "${join("", aws_elb.elk_elb.*.id)}"
}

output "elb_dns_name" {
  value = "${join("", aws_elb.elk_elb.*.dns_name)}"
}

output "elb_zone_id" {
  value = "${join("", aws_elb.elk_elb.*.zone_id)}"
}
