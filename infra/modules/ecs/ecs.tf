resource "aws_ecs_cluster" "gatus-ecs" {
  name = "gatus-deployment"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.gatus-ecs.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}


resource "aws_ecs_task_definition" "gatus-task" {
  family = "service"
  container_definitions = 
    {
      name      = "fargate"
      image     = "${var.repository_url}:latest"
      cpu       = 1024
      memory    = 512
      essential = true
      task_role_arn = var.execution_role_arn
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }}


    resource "aws_ecs_service" "gatus" {
  name            = "gatus"
  cluster         = aws_ecs_cluster.gatus-ecs.id
  task_definition = aws_ecs_task_definition.gatus-task.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = var.tg_arn  
    container_name   = "gatus"
    container_port   = 8080
  }
  
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.ecs_sg
    assign_public_ip = false  
  }
  
  }