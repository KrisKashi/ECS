variable "security_group_ids" {
    type = list(string)   
}

variable "subnet_ids" {
    type = list(string)   
}

variable "vpc_id" {
    type = string   
}


variable "cert_arn" {
    type = string
}