output "certificate_arn" {
  value       = aws_acm_certificate_validation.cert_validation.certificate_arn
  description = "ARN of the validated ACM certificate."
}

output "zone_id" {
  value       = data.aws_route53_zone.zone.zone_id
  description = "ID of the Route53 hosted zone."
}
