
variable "subnet_ids" {
  type = list(string)
}

variable "cert_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "self_sg" {
  type = string
}