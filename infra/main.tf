
module "acm" {
  source = "./modules/acm"
  cloudflare_token = var.cloudflare_token
  cloudflare_zone_id = var.cloudflare_zone_id

  alb_dns = module.alb.alb_dns
  
}

module "alb" {
    source = "./modules/alb"
    security_group_ids = [aws_security_group.web-sg.id, aws_security_group.self_rf.id]
    subnet_ids = module.vpc.subnet_ids # takes output values from modules
    vpc_id = module.vpc.vpc_id
    cert_arn = module.acm.cert_arn
    acm_cert =module.acm.acm_cert

}

module "ecr" {
    source = "./modules/ecr"
}

module "iam" {
    source = "./modules/iam"

}

module "ecs" {
    source = "./modules/ecs"
    repository_url = module.ecr.repository_url
    execution_role_arn = module.iam.execution_role_arn
    tg_arn = module.alb.tg_arn
    subnet_ids = module.vpc.subnet_ids
    ecs_sg = [aws_security_group.self_rf.id] # is a list to satisfy ecs module sg reqs
}




module "vpc"{
    source = "./modules/vpc"
}


resource "aws_security_group" "web-sg" {   # Security group 1 Client to  ALB
    name = "web-sg"
    vpc_id = module.vpc.vpc_id
    ingress {
    from_port   = 80    #http
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

    ingress { #https
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }

}

resource "aws_security_group" "self_rf" {   # Security group 2 ALB and ECS
    name = "self_rf"
    vpc_id = module.vpc.vpc_id
    ingress {
    from_port   = 8080    #speaks to alb via tg port 8008 http traffic
    to_port     = 8080
    protocol    = "tcp"
    self = true
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"             # internet acess for ecs to pull image 
        cidr_blocks = ["0.0.0.0/0"]

    }
}

