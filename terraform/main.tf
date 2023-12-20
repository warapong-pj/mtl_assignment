variable "region" {
  default = "ap-southeast-1"
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = "demo-cluster"
  cluster_version = "1.28"
  cluster_endpoint_public_access = true
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
  create_cloudwatch_log_group = false

  vpc_id = "vpc-01e578fe189e6ebf3"
  subnet_ids = [
    "subnet-0921cbf30320d0be5",
    "subnet-0aafa3b6eb8728b76",
    "subnet-04b7f0d706e02e9b3"
  ]

  create_aws_auth_configmap = false
  manage_aws_auth_configmap = true
  aws_auth_users = [
    {
      rolearn  = "arn:aws:iam::XXXXXXXXXXXX:user/test"
      username = "test"
      groups   = ["system:masters"]
    },
  ]

  eks_managed_node_groups = {
    generic = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = [
        "t3.medium",
        "t3a.medium"
      ]
    }
  }
}

module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = "my-web-assets"
}

module "iam_s3_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.33.0"

  name        = "eks-access-to-s3"
  path        = "/"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": [
				"s3:PutObject",
				"s3:GetObject"
			],
			"Resource": "arn:aws:s3:::my-web-assets/*"
		}
	]
}
EOF
}


module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.1.0"

  name = "lms-import-data"
}

module "iam_sqs_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.33.0"

  name        = "eks-access-to-sqs"
  path        = "/"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": [
				"sqs:ReceiveMessage",
				"sqs:DeleteQueue",
				"sqs:SendMessage"
			],
			"Resource": "arn:aws:sqs:ap-southeast-1:XXXXXXXXXXXX:lms-import-data"
		}
	]
}
EOF
}
