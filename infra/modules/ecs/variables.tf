variable "execution_role_arn" {
  type = string
}

variable "repository_url" {
  type = string
}

variable "tg_arn" {
  type = string
}

variable "subnet_ids_ecs" {
  type = list(string)
}

variable "image_tag" {
  type = string
}

variable "ecs_cpu" {
  type = string

}

variable "ecs_memory" {
  type = string

}


variable "vpc_id" {
  type = string

}