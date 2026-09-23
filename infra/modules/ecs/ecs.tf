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
  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = var.execution_role_arn
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
  name                 = "gatus"
  cluster              = aws_ecs_cluster.gatus-ecs.id
  task_definition      = aws_ecs_task_definition.gatus-task.arn
  desired_count        = 1
  force_new_deployment = true
  launch_type          = "FARGATE"

  load_balancer {
    target_group_arn = var.tg_arn
    container_name   = "gatus"
    container_port   = 8080
  }

  network_configuration {
    subnets          = var.subnet_ids_ecs
    security_groups  = [aws_security_group.self_rf.id]
    assign_public_ip = false ##  public ip not needed now that we use private subnet  
  }

}

resource "aws_security_group" "self_rf" { # Security group 2 ALB and ECS
  name   = "self_rf"
  vpc_id = var.vpc_id
  ingress {
    from_port = 8080 #speaks to alb via tg port 8080 http traffic
    to_port   = 8080
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # internet acess for ecs to pull image 
    cidr_blocks = ["0.0.0.0/0"]

  }
}