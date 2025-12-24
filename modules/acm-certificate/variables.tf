variable "fqdn" {
  type        = string
  description = "the fqdn of the subdomain. it creates a wildcard certificate for this subdomain valid for non-prod devops tools"
}

variable "domain_zone_id" {
  type = string
}