variable "tenant_id" {
  type        = string
  default     = "48f3dbef-a421-4fcb-9061-83677564f5c6"
  description = "The Microsoft Entra ID Tenant ID."
}

variable "subscription_id" {
  type        = string
  default     = "c168929a-65ae-44f4-b7b0-9cdf686f737a"
  description = "The Azure Subscription ID."
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Deployment environment tag."
}

variable "project_name" {
  type        = string
  default     = "entra-lcw-gitops"
  description = "Prefix applied to created resources."
}