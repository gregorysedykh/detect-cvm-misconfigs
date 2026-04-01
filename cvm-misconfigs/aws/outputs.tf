output "public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.cvm-test.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.cvm-test.id
}
