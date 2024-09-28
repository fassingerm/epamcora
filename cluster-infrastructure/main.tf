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

provider "kubernetes" {
  host = module.cluster-infra.cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster-infra.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.cluster-infra.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host = module.cluster-infra.cluster_endpoint
    cluster_ca_certificate = base64decode(module.cluster-infra.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.cluster-infra.cluster_name]
    }
  }
}

provider "postgresql" {
  host      = module.cluster-infra.rds_address
  port      = module.cluster-infra.rds_port
  username  = module.cluster-infra.rds_root_username
  password  = module.cluster-infra.rds_root_pass_secret
  superuser = false
}

module "cluster-infra" {
  source                            = "git::https://github.com/epam/cloud-pipeline//deploy/infra/aws/terraform/cloud-native/jump-server?ref=f_aws_native_infra"
  deployment_name                   = "epamcora"
  deployment_env                    = "epamcora"
  vpc_id                            = "vpc-0415aa7113325d810"
  external_access_security_group_ids = ["sg-01a791bd25d30e19f", "sg-0363b3eeeaf47e0ff", "sg-02297098f72413c84"]
  subnet_id = ["subnet-0d985becaf3d61365", "subnet-0d1dc3754fd992800", "subnet-0c76eb51b5d594177"]
  iam_role_permissions_boundary_arn = "arn:aws:iam::xxxxxxxxxxxx:policy/eo_role_boundary"
  eks_system_node_group_subnet_ids = ["subnet-0d985becaf3d61365"]
  cp_edge_elb_schema                = "internet-facing"
  cp_edge_elb_subnet                = "subnet-0328f9741afa1722c"
  cp_edge_elb_ip                    = "3.132.102.165"
  cp_api_srv_host                   = "epam.fascmari.people.aws.dev"
  cp_docker_host                    = "docker.epam.fascmari.people.aws.dev"
  cp_edge_host                      = "edge.epam.fascmari.people.aws.dev"
  cp_gitlab_host                    = "git.epam.fascmari.people.aws.dev"
  eks_additional_role_mapping = [
    {
      iam_role_arn  = "arn:aws:iam::590788709872:role/epamcora-BastionExecutionRole"
      eks_role_name = "system:node:{{EC2PrivateDNSName}}"
      eks_groups = ["system:bootstrappers", "system:nodes"]
    }
  ]
} 
