resource "aws_acm_certificate" "cert" {
  domain_name       = "kristenhaslam.com"
  validation_method = "DNS"                 # request to issue a cert 

  lifecycle {
    create_before_destroy = true
  }
}


resource "cloudflare_dns_record" "kristendns" { # use cloudflare provider to validate ownership to issue cert
  zone_id = var.cloudflare_zone_id
  name = aws_acm_certificate.cert.domain_validation_options[0].resource_record_name # takes first value from list of record names created from ACM which will be the one we just requested
  ttl = 3600
  type = "CNAME"
  comment = "Domain verification record"
  content = aws_acm_certificate.cert.domain_validation_options[0].resource_record_value
  proxied = false
  tags = ["cloudflare-dns"]
}

resource "cloudflare_dns_record" "alb-dns" { # points domain to alb DNS by creating record
  zone_id = var.cloudflare_zone_id
  name = "kristenhaslam.com"
  ttl = 3600
  type = "CNAME"
  comment = "ALB dns"
  content = var.alb_dns
  proxied = false
  tags = ["alb-dns"]
}

resource "aws_acm_certificate_validation" "dns" { #checks to see if the record exists
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns =[aws_acm_certificate.cert.domain_validation_options[0].resource_record_name] #Hostname declared explicitly as theres reported bugs in the clouudflare terraform module referencing.
}