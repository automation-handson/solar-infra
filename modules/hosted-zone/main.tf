# 1. Create the Root Zone ONLY if root_domain_name is provided
resource "aws_route53_zone" "root_domain" {
  count = var.root_domain_name != null ? 1 : 0
  name  = var.root_domain_name
}

# 2. Lookup the Root Zone ID if we didn't create it
data "aws_route53_zone" "existing_root_domain" {
  count = var.root_domain_name == null ? 1 : 0
  name  = join(".", slice(split(".", var.sub_domain_name), 1, length(split(".", var.sub_domain_name))))
  # This logic extracts 'example.com' from 'dev.example.com'
}

# 3. Automatically update the Registrar (Registered Domain) 
# to use the Name Servers from the zone above
resource "aws_route53domains_registered_domain" "root_hosted_zone_registration" {
  count       = var.root_domain_name != null ? 1 : 0
  domain_name = var.root_domain_name

  # This pulls the 4 servers from the zone you just created
  dynamic "name_server" {
    for_each = aws_route53_zone.root_domain[0].name_servers
    content {
      name = name_server.value
    }
  }
}

# 4. Always create the Subdomain Zone
resource "aws_route53_zone" "sub_domain" {
  name = var.sub_domain_name
}

# 5. Delegation: Create NS records in the Root Zone pointing to the Subdomain
resource "aws_route53_record" "ns_delegation" {
  # Logic: Use the created zone ID or the existing one
  zone_id = var.root_domain_name != null ? aws_route53_zone.root_domain[0].zone_id : data.aws_route53_zone.existing_root_domain[0].zone_id

  name = var.sub_domain_name
  type = "NS"
  ttl  = "30"

  records = aws_route53_zone.sub_domain.name_servers
}