output "public_ip" {
  value = aws_instance.helm_instance.public_ip
}

# Output the Public DNS of the EC2 instance
output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.helm_instance.public_dns
}

# Output the SSH connection string
output "ssh_connection" {
  description = "Example SSH command to connect to the instance"
  value       = "ssh -i \"${local_file.tf_key.filename}\" ec2-user@${aws_instance.helm_instance.public_dns}"
}
