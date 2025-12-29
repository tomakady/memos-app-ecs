locals {
  subdomain = "tm.${var.domain_name}"
  app_url   = "https://${local.subdomain}"
}

