resource "aws_vpc" "vpc" {
  // The CIDR block for the VPC
  cidr_block = "${var.vpc_cidr}"

  // A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false.
  enable_dns_hostnames = true

  // A boolean flag to enable/disable DNS support in the VPC. Defaults true.
  enable_dns_support = true

  tags {
    Name = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  // Boolean if the EIP is in a VPC or not.
  vpc = true
  depends_on = [
    "aws_internet_gateway.igw"]
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  // The VPC ID.
  vpc_id                  = "${aws_vpc.vpc.id}"

  // The CIDR block for the subnet.
  cidr_block              = "${var.public_subnet_cidr}"

  // The AZ for the subnet.
  availability_zone       = "${var.availability_zone}"

  // Specify true to indicate that instances launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  tags {
    Name        = "${var.environment}-public-subnet"
    Environment = "${var.environment}"
  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  // The VPC ID.
  vpc_id                  = "${aws_vpc.vpc.id}"

  // The CIDR block for the subnet.
  cidr_block              = "${var.private_subnet_cidr}"

  // The AZ for the subnet.
  availability_zone       = "${var.availability_zone}"

  tags {
    Name        = "${var.environment}-private-subnet"
    Environment = "${var.environment}"
  }
}

/* Provides a resource to create a VPC NAT Gateway. */
resource "aws_nat_gateway" "nat" {
  // The Allocation ID of the Elastic IP address for the gateway.
  allocation_id = "${aws_eip.nat_eip.id}"

  // The Subnet ID of the subnet in which to place the gateway.
  subnet_id     = "${aws_subnet.public_subnet.id}"

  tags {
    Name = "${var.environment}-nat"
    Environment = "${var.environment}"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  // The VPC ID.
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  // The VPC ID.
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}

// aws_route provides details about a public routes.
resource "aws_route" "public_internet_gateway" {
  // The ID of the routing table.
  route_table_id         = "${aws_route_table.public.id}"

  // The destination CIDR block.
  destination_cidr_block = "0.0.0.0/0"

  // An ID of a VPC internet gateway or a virtual private gateway.
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

// aws_route provides details about a private routes.
resource "aws_route" "private_nat_gateway" {
  // The ID of the routing table.
  route_table_id         = "${aws_route_table.private.id}"

  // The destination CIDR block.
  destination_cidr_block = "0.0.0.0/0"

  // An ID of a VPC internet gateway or a virtual private gateway.
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  // The subnet ID to create an association.
  subnet_id      = "${aws_subnet.public_subnet.id}"

  // The ID of the routing table to associate with.
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  // The subnet ID to create an association.
  subnet_id       = "${aws_subnet.private_subnet.id}"

  // The ID of the routing table to associate with.
  route_table_id  = "${aws_route_table.private.id}"
}

/* Default security group */
resource "aws_security_group" "default" {
  // The name of the security group
  name        = "${var.environment}-default-sg"

  description = "Default security group to allow inbound/outbound from the VPC"

  // The VPC ID.
  vpc_id      = "${aws_vpc.vpc.id}"

  // Inbound rules
  ingress {
    // The start port
    from_port = "0"

    // The end range port
    to_port   = "0"
    // The protocol. If you select a protocol of "-1" (semantically equivalent to "all", which is not a valid value here),
    // you must specify a "from_port" and "to_port" equal to 0
    protocol  = "-1"

    // If true, the security group itself will be added as a source to this ingress rule.
    self      = true
  }

  // Outgoing rules
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "bastion" {
  // The name of the security group
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "${var.environment}-bastion-host"
  description = "Allow SSH to bastion host"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    // List of CIDR blocks.
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    // List of CIDR blocks.
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    // List of CIDR blocks.
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.environment}-bastion-sg"
    Environment = "${var.environment}"
  }
}

// Provides an EC2 bastion instance resource.
resource "aws_instance" "bastion" {
  // The AMI to use for the instance.
  ami                         = "${lookup(var.bastion_ami, var.region)}"

  // The type of instance to start
  instance_type               = "t2.micro"

  // The key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource.
  key_name                    = "${var.key_name}"

  // If true, the launched EC2 instance will have detailed monitoring enabled.
  monitoring                  = true

  // A list of security group IDs to associate with.
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]

  // The VPC Subnet ID to launch in.
  subnet_id                   = "${aws_subnet.public_subnet.id}"

  // Associate a public ip address with an instance in a VPC. Boolean value.
  associate_public_ip_address = true

  tags {
    Name        = "${var.environment}-bastion"
    Environment = "${var.environment}"
  }
}