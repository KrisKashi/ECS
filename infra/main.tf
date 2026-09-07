resource "aws_security_group" "web-sg" {   # Security group 1 Client to  ALB
    name = "web-sg"
    vpc_id = aws_vpc.main.id
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

resource "aws_security_group" "self-rf" {   # Security group 2 ALB and ECS
    name = "self-rf"
    vpc_id = aws_vpc.main.id
    ingress {
    from_port   = 8080    
    to_port     = 8080
    protocol    = "tcp"
    self = true
}
}