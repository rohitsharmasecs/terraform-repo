provider "aws" {
  region = var.region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = var.public_subnet_AZ
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = var.private_subnet_AZ

  tags = {
    Name = var.private_subnet_name
  }
}

resource "aws_internet_gateway" "Internet_Gateway" {
  depends_on = [
    aws_vpc.my_vpc,
    aws_subnet.subnet-1,
    aws_subnet.subnet-2
  ]
  
  # VPC in which it has to be created!
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.IG_name
  }
}

# Creating an Route Table for the public subnet!
resource "aws_route_table" "Public-Subnet-RT" {
  depends_on = [
    aws_vpc.my_vpc,
    aws_internet_gateway.Internet_Gateway
  ]

   # VPC ID
  vpc_id = aws_vpc.my_vpc.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }

  tags = {
    Name = "Route Table for Internet Gateway"
  }
}

# Creating a resource for the Route Table Association!
resource "aws_route_table_association" "RT-IG-Association" {

  depends_on = [
    aws_vpc.my_vpc,
    aws_subnet.subnet-1,
    aws_route_table.Public-Subnet-RT
  ]

# Public Subnet ID
  subnet_id      = aws_subnet.subnet-1.id

#  Route Table ID
  route_table_id = aws_route_table.Public-Subnet-RT.id
}

# Elatic ip ->>>

resource "aws_eip" "my_eip"{
  vpc = true
  tags = {
    Name = var.eip_name
  }
}
# Creating NAT gateway -->

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.subnet-1.id

  tags = {
    Name = var.NAT_GATEWAY
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.Internet_Gateway]
}

# Creating an Route Table for the private subnet!
resource "aws_route_table" "Private-Subnet-RT" {
  depends_on = [
    aws_vpc.my_vpc,
    aws_nat_gateway.nat-gateway
  ]

   # VPC ID
  vpc_id = aws_vpc.my_vpc.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = "Route Table for NAT gateway"
  }
}

# Creating a resource for the Route Table Association!
resource "aws_route_table_association" "RT-NAT-Association" {

  depends_on = [
    aws_vpc.my_vpc,
    aws_subnet.subnet-2,
    aws_route_table.Private-Subnet-RT
  ]

# Private Subnet ID
  subnet_id      = aws_subnet.subnet-2.id

#  Route Table ID
  route_table_id = aws_route_table.Private-Subnet-RT.id
}

 

#Creating Security group --->>>

resource "aws_security_group" "Security_Group" {
  vpc_id       = aws_vpc.my_vpc.id
  name         = var.SG
  description  = "Security Group"

  # allow ingress of port 22
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description       = "http"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }
  ingress {
    description       = "Custom tcp"
    from_port         = 8080
    to_port           = 8080
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
} 

#Creating EC2 in public subnet --->

resource "aws_instance" "web_instance-1" {
  ami           = var.ami_id
  instance_type = var.public_instance_typee
  key_name      = var.key_pair_namee

  subnet_id                   = aws_subnet.subnet-1.id
  vpc_security_group_ids      = [aws_security_group.Security_Group.id]
  associate_public_ip_address = true
  tags = {
    Name = var.public_instance_name
  }
  user_data = <<-EOF
  #!/bin/bash
  sudo apt update
  sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  apt-cache policy docker-ce
  sudo apt install docker-ce -y
  EOF

}  

# Creating EC2 in private subnet --->

resource "aws_instance" "web_instance-2" {
  ami           = var.private_ami_id
  instance_type = var.private_instance_typee
  key_name      = var.private_key_pair_namee

  subnet_id                   = aws_subnet.subnet-2.id
  vpc_security_group_ids      = [aws_security_group.Security_Group.id]
  associate_public_ip_address = false
  tags = {
    Name = var.private_instance_name
  }
  user_data = <<-EOF
  #!/bin/bash
  sudo apt update
  sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  apt-cache policy docker-ce
  sudo apt install docker-ce -y
  EOF
}
