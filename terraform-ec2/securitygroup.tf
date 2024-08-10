#public ec2 security group
resource "aws_security_group" "allow_traffic" {
  name        = "allow_tcp"
  description = "Allow TCP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.mainvpc.id

  tags = {
    Name = "allow_TCP"
  }
}

#rules for the public SG
resource "aws_vpc_security_group_ingress_rule" "allow_tcp" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = "77.107.233.162/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = "104.30.176.2/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_connection_to_DB" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = "104.30.176.2/32"
  from_port         = 27017
  ip_protocol       = "tcp"
  to_port           = 27019
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

