output "s3_bucket_name" {
  value = aws_s3_bucket.this.id
}

output "dns_zone" {
  value = aws_route53_zone.this.name
}

output "dns_ns" {
  value = aws_route53_zone.this.name_servers
}

output "instance_dns" {
  value = aws_instance.this.public_dns
}