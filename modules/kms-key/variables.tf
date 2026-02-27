variable "account_id" {
  type        = string
  description = "The AWS account ID"
}

variable "key_name" {
  type        = string
  description = "The name of the key"
}

variable "key_admins_list" {
  type        = list(string)
  description = "The list of admin users to administrate this key"
}

variable "key_role_list" {
  type        = list(string)
  description = "The list of iam roles that can consume the key"
}