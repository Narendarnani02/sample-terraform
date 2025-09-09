output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.web.public_dns
}

output "s3_bucket_name" {
  value = aws_s3_bucket.project_bucket.bucket
}
