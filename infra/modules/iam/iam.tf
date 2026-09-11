resource "aws_iam_role" "ecs-execution" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"   #creates empty role and allows ECS to become the role
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  }


resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs-execution.name                                              #attaches required policy to empty role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
