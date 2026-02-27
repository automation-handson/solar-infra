variable "pod_identities" {
  description = "List of pod identities to create"
  type = list(object({
    name            = string
    namespace       = string
    service_account = string
    policy_json     = string # The raw IAM policy JSON
  }))
}

variable "cluster_name" {
  type = string
}