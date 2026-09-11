output "acm_cert" { value = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name }
output "cert_arn" { value = aws_acm_certificate.cert.arn }