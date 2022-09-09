variable "dependencies" {
  description = "List of module dependencies to wait on"
  type = list
  default = []
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster to deploy resources to"
  type = string
}

variable "namespaces" {
  description = "Kubernetes namespaces to deploy the Service Account to. These must exist beforehand."
  type = list(string)
}

variable "common_tags" {
  description = "Common tags to use"
  type = map(string)
}

variable "name" {
  description = "Base name of the IAM role and service account to be created"
  type = string
}

variable "oidc_provider_url" {
  description = "URL of the OpenID connect provider from the EKS cluster"
  type = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OpenID connect provider from the EKS cluster"
  type = string
}

variable "access_policy_arn" {
  description = "ARN of the access policy used to give the role access to AWS resources"
  type = string
}

variable "create_service_account" {
  description = "Whether to create the Service account resource."
  type = bool
  default = false
}
