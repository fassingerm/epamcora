terraform {
  backend "s3" {
    bucket         = "5907epamcoraohio"
    key            = "cora-jumpbox/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "epamcoraohio"
  }
  required_version = "1.5.0"
}

provider "aws" {
  region = "us-east-2"
}

module jump-server {
  source                            = "git::https://github.com/epam/cloud-pipeline//deploy/infra/aws/terraform/cloud-native/jump-server?ref=f_aws_native_infra"
  vpc_id                            = "vpc-0415aa7113325d810"
  subnet_id                         = "subnet-0328f9741afa1722c"
  iam_role_permissions_boundary_arn = "arn:aws:iam::590788709872:policy/CP-Service-Policy"
  deployment_name                   = "epamcora"
  deployment_env                    = "epamcora"
}