variable "execution_role_arn" {
    type = string   
}

variable "repository_url" {
    type = string   
}

variable "tg_arn" {
    type = string   
}

variable "subnet_ids" {
    type = list(string)   
}

variable "ecs_sg" {
    type = list(string)
}