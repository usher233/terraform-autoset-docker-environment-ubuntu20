

# VPC
resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = {
    Name = "dev"
  }
}

# Subnet
resource "aws_subnet" "mtc_public_subnet" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "${var.public_subnet_cidr}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.az}"

  tags = {
    Name = "dev-public"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "mtc_igw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "dev-igw"
  }
}



# Route Table
resource "aws_route_table" "mtc_public_route_table" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "mtc_public_route_table"
  }
}


# Route
resource "aws_route" "mct_default_route" {
  route_table_id         = aws_route_table.mtc_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_igw.id
}

# Route Table Association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mtc_public_subnet.id
  route_table_id = aws_route_table.mtc_public_route_table.id
}


# Security Group
resource "aws_security_group" "mtc_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Key Pair
resource "aws_key_pair" "mtc_auth" {
  key_name   = "mtckey"
  public_key = file("~/.ssh/mtckey.pub")
}


# EC2 Instance
resource "aws_instance" "dev_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "${var.instance_type}"
  key_name               = aws_key_pair.mtc_auth.key_name
  subnet_id              = aws_subnet.mtc_public_subnet.id
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  user_data              = file("userdata.tpl")


  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = "dev_node"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/mtckey"
    })
    interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["powershell", "-Command"]

  }
}

