
output "s3_bucket_name" {
  description = "Begad-Test-Prowler"
  value       = aws_s3_bucket.app_data.bucket
}

output "security_group_id" {
  description = "ID of the test security group"
  value       = aws_security_group.app_sg.id
}

output "ec2_instance_id" {
  description = "ID of the test EC2 instance"
  value       = aws_instance.app.id
}
