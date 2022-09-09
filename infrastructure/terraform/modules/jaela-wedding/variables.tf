variable "cluster-name" {
  type    = string
}

variable "service-name" {
  type    = string
  default = "jaela-wedding"
}

variable "ses-domain" {
  type    = string
  default = "wedding.jaela.us"
}

variable "environment" {
  type    = string
  default = "prod"
}
