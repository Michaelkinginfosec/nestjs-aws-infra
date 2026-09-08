# NestJS AWS Infrastructure (Terraform)

Infrastructure-as-code for a containerized NestJS API on AWS, built with
Terraform. Provisions a custom VPC with correctly separated public/private
subnets, NAT Gateway for secure outbound-only private access, and an ECR
repository with an automated image lifecycle policy.

This project was built as a hands-on learning exercise, translating a
previously manually-built AWS setup (ECR, ECS, ALB, OIDC-based CI/CD) into
fully reproducible Terraform code.

## Architecture

![Architecture Diagram](./diagram.png)

The VPC separates public and private traffic paths at the routing layer:

- **Public subnet** → routes `0.0.0.0/0` to an Internet Gateway (bidirectional internet access)
- **Private subnet** → routes `0.0.0.0/0` to a NAT Gateway (outbound-only — cannot be reached from the internet)

This mirrors the security principle applied throughout this project: nothing
that doesn't need direct internet exposure should have it.

## Key Design Decisions

- **NAT Gateway lives in the public subnet, not the private one** — it needs
  its own path to the internet via the Internet Gateway before it can forward
  traffic on behalf of private-subnet resources.
- **Public vs private is determined by the route table, not a label** — AWS
  has no literal "make this subnet public" setting. A subnet is public only
  because its associated route table sends unmatched traffic to an Internet
  Gateway.
- **ECR uses a lifecycle policy** to automatically expire images beyond the
  5 most recent, preventing unbounded storage cost growth in CI/CD pipelines
  that push an image on every commit.

## What's Next

- ECS Fargate + Application Load Balancer, rebuilt inside this VPC (currently
  built manually via console — being migrated to Terraform)
- GitHub Actions OIDC-based CI/CD, connecting this infrastructure to an
  automated build/deploy pipeline

---

## Resource Reference

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                   | Version |
| ------------------------------------------------------ | ------- |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 5.0  |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                   | Type     |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_ecr_lifecycle_policy.michael_nest_app_lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy)         | resource |
| [aws_ecr_repository.michael_nest_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)                                      | resource |
| [aws_eip.michael_nest_nat_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                                        | resource |
| [aws_instance.michaelking_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)                                              | resource |
| [aws_internet_gateway.michael_nest_vpc_ig](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)                               | resource |
| [aws_nat_gateway.michael_nest_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)                                            | resource |
| [aws_route_table.michael_nest_private_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                     | resource |
| [aws_route_table.michael_nest_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                             | resource |
| [aws_route_table_association.michael_nest_private_rt_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.michael_nest_rt_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)         | resource |
| [aws_security_group.allow_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                            | resource |
| [aws_subnet.michael_nest_private_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                           | resource |
| [aws_subnet.michael_nest_public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                            | resource |
| [aws_vpc.michael_nest_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)                                                            | resource |

## Inputs

No inputs.

## Outputs

No outputs.

<!-- END_TF_DOCS -->
