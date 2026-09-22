
module "acm" {
  source = "./modules/acm"
  cloudflare_zone_id = var.cloudflare_zone_id

  alb_dns = module.alb.alb_dns
  
}

module "alb" {
    source = "./modules/alb"
    self_sg = module.ecs.self_sg
    subnet_ids = module.vpc.subnet_ids # takes output values from modules
    vpc_id = module.vpc.vpc_id
    cert_arn = module.acm.cert_arn
   

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
    image_tag = var.image_tag
    ecs_cpu = "256"
    ecs_memory = "512"
    vpc_id = module.vpc.vpc_id
}

module "vpc"{
    source = "./modules/vpc"
}




