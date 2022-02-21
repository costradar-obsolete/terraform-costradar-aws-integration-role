variable "costradar_role_arn" {
  description = "ARN of the costradar role that will assume the integration role."
  type        = string
}

variable "external_id" {
  description = "External ID for assuming the role. If will be added to assume policy and must be provided to costradar."
  type        = string
}

variable "role_name" {
  description = "Name of the role that will be crated. Either role_name or role_prefix should be provided."
  type        = string
  default     = null
}

variable "role_name_prefix" {
  description = "Prefix of the role that will be crated. Either role_prefix or role_name should be provided."
  type        = string
  default     = null
}

variable "cur" {
  type = object({
    bucket = string
  })
  default = null
}

variable "cloudtrail" {
  type = object({
    bucket = string
  })
  default = null
}

variable "permissions_boundary_arn" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "path" {
  type    = string
  default = null
}
