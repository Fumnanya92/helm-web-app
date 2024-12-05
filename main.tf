# Generate SSH Key Pair for EC2
resource "tls_private_key" "helm" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "helm_keypair" {
  key_name   = "helmkey"
  public_key = tls_private_key.helm.public_key_openssh
}

# Save the private key locally
resource "local_file" "tf_key" {
  content  = tls_private_key.helm.private_key_pem
  filename = "helmkey.pem"
}

# Create Elastic IP for the instance (optional for public access)
resource "aws_eip" "helm_eip" {
  domain = "vpc" # Specifies that this is for use in a VPC
}

# EC2 Instance Configuration
resource "aws_instance" "helm_instance" {
  ami                         = "ami-066a7fbea5161f451" # Replace with appropriate AMI ID
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.helm_keypair.key_name
  vpc_security_group_ids      = [aws_security_group.helm_sg.id] # Use the passed subnet ID
  associate_public_ip_address = true                            # Associates a public IP

  # User data for EC2 instance configuration
  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "helm-instance"
  }
}

resource "aws_ec2_instance_state" "helm_instance_state" {
  instance_id = aws_instance.helm_instance.id
  state       = var.instance_state # "running" or "stopped"
}


# Associate Elastic IP with the instance (optional for dedicated IP)
resource "aws_eip_association" "helm_eip_association" {
  instance_id   = aws_instance.helm_instance.id
  allocation_id = aws_eip.helm_eip.id
}

# Security Group Configuration for helm and RDS instances
resource "aws_security_group" "helm_sg" {
  name_prefix = "helm-sg"
  description = "Security group for helm and RDS instances"

  # HTTP (80) - Allow for web access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS (443) - Allow for secure web access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # SSH (22) - Allow access dynamically from EC2 instance IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Reference EC2 public IP
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}