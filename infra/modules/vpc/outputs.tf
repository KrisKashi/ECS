output "subnet_ids" { value = [aws_subnet.subnet-1.id,aws_subnet.subnet-2.id] }
output "vpc_cidr" { value = [aws_vpc.main.cidr_block]}
output "vpc_id" { value = [aws_vpc.main.id] }