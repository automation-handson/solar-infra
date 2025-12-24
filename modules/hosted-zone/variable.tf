variable "root_domain_name" {
  type        = string
  default     = null
  description = "If specified, tf will create a root hosted zone. if not, tf will skip the root domain and create a subdomain"
}

variable "sub_domain_name" {
  type        = string
  description = "The subdomain name to create the hosted zone for, e.g., dev.example.com"
}