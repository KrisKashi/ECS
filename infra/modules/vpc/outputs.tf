output "subnet_ids" { value = aws_subnet.subnet[*].id }
output "priv_subnet_ids" { value = aws_subnet.subnet_priv[*].id }
output "vpc_cidr" { value = aws_vpc.main.cidr_block }
output "vpc_id" { value = aws_vpc.main.id }