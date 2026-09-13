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
}

resource "aws_ecs_task_definition" "gatus-task" {
  family = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu       = 256
  memory    = 512
  execution_role_arn = var.execution_role_arn
  container_definitions = jsonencode([
    {
      name      = "gatus"
      image     = "${var.repository_url}:${var.image_tag}"
      
      essential = true
      
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }])
    }


    resource "aws_ecs_service" "gatus" {
  name            = "gatus"
  cluster         = aws_ecs_cluster.gatus-ecs.id
  task_definition = aws_ecs_task_definition.gatus-task.arn
  desired_count   = 1
  force_new_deployment = true
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = var.tg_arn  
    container_name   = "gatus"
    container_port   = 8080
  }
  
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.ecs_sg
    assign_public_ip = true  
  }
  
  }