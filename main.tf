resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-VPC"
  }
}

resource "aws_subnet" "dev_public_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id #Access the VPC ID in tfstate created previously
  cidr_block              = "10.123.1.0/24"    #Needs to be inside cidr of VPC
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "${var.environment}-PUBLIC"
  }
}

resource "aws_internet_gateway" "dev_internet_gateway" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "${var.environment}-INTERNET_GW"
  }
}

resource "aws_route_table" "dev_public_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "${var.environment}-PUBLIC-ROUTE-TABLE"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.dev_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_internet_gateway.id
}

resource "aws_route_table_association" "dev_public_route_table_association" {
  subnet_id      = aws_subnet.dev_public_subnet.id
  route_table_id = aws_route_table.dev_public_route_table.id
}

resource "aws_security_group" "dev_security_group" {
  name        = "${var.environment}-SECURITY-GROUP"
  description = "${var.environment} SECURITY GROUP"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress { # Allow all inbound traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [""] #Your public IP Address followed by /32
  }

  egress { # Allow all outbound traffic (Internet)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "dev_auth" {
  key_name   = "${var.environment}-KEY"
  public_key = file("${var.path_to_key_pub}")
}

# Create EC2 instance
resource "aws_instance" "dev_instance" {
  ami                    = data.aws_ami.ubuntu_server_ami.id
  instance_type          = "${var.ec2_instance_type}"
  vpc_security_group_ids = [aws_security_group.dev_security_group.id]
  key_name               = aws_key_pair.dev_auth.key_name
  subnet_id              = aws_subnet.dev_public_subnet.id
  user_data              = file("${var.path_to_userdata}")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "${var.environment}-INSTANCE"
  }

  provisioner "local-exec" {
    command = templatefile("${var.path_to_ssh_config}", {
      hostname = self.public_ip,
      username = "ubuntu",
      identityfile = "${var.path_to_key}"
    })
    interpreter = ["bash", "-c"]
  }
}
