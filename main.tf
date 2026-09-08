

resource "aws_ecr_repository" "michael_nest_app"{
    name = "nest-app"
    image_tag_mutability =  "MUTABLE"

    encryption_configuration {
      encryption_type = "AES256"
    }
}

resource "aws_ecr_lifecycle_policy" "michael_nest_app_lifecycle_policy"{
    repository = aws_ecr_repository.michael_nest_app.name
    policy = jsonencode({
        rules = [
            {
                rulePriority = 1
                description  = "keep last 5 image delete older"
                selection = {
                tagStatus   = "any"
                countType   = "imageCountMoreThan"
                countNumber = 5
                }
                action = {
                type = "expire"
                }
            }
        ]
    })
}

# aws ec2 resource 

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "michaelking_instance" {
    ami  = "ami-0aba19e56f3eaec05"
    instance_type = "t3.micro"
    key_name = "demo-aws-keys"
    vpc_security_group_ids = [aws_security_group.allow_http.id]



    user_data = <<-EOF
                #!/bin/bash
                apt update -y
                apt install -y nginx
                systemctl start nginx
                systemctl enable nginx
                EOF

    tags = {
        Name = "michaelking-instance"
    }
}
