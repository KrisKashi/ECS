variable "security_group_ids" {
    type = list(string)   
}

variable "subnet_ids" {
    type = list(string)   
}

variable "vpc_id" {
    type = string   
}

variable "acm_cert" {
    type = string
}