data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  count           = var.create_oidc_provider ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  tags            = merge(var.default_tags, { Name = "github-actions-oidc-provider" })
}

resource "aws_iam_role" "pipeline" {
  name        = "${var.environment}-eks-pipeline-role"
  description = "Assumed by GitHub Actions via OIDC to provision EKS and deploy WordPress"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "GitHubActionsOIDC"
      Effect = "Allow"
      Principal = {
        Federated = var.create_oidc_provider ? (
          aws_iam_openid_connect_provider.github[0].arn
        ) : (
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        )
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })

  tags = merge(var.default_tags, { Name = "${var.environment}-eks-pipeline-role" })
}

resource "aws_iam_policy" "pipeline" {
  name        = "${var.environment}-eks-pipeline-policy"
  description = "Permissions for the GitHub Actions EKS + WordPress pipeline"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "CallerIdentity"
        Effect   = "Allow"
        Action   = ["sts:GetCallerIdentity"]
        Resource = "*"
      },
      {
        Sid    = "TerraformStateS3"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject",
                  "s3:ListBucket", "s3:GetBucketVersioning", "s3:GetEncryptionConfiguration"]
        Resource = ["arn:aws:s3:::${var.state_bucket_name}",
                    "arn:aws:s3:::${var.state_bucket_name}/*"]
      },
      {
        Sid    = "TerraformStateLock"
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:PutItem",
                  "dynamodb:DeleteItem", "dynamodb:DescribeTable"]
        Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.lock_table_name}"
      },
      {
        Sid    = "VPC"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:DescribeVpcs",
          "ec2:ModifyVpcAttribute", "ec2:DescribeVpcAttribute",
          "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:DescribeSubnets",
          "ec2:ModifySubnetAttribute", "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway", "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway", "ec2:DescribeInternetGateways",
          "ec2:AllocateAddress", "ec2:ReleaseAddress", "ec2:DescribeAddresses",
          "ec2:CreateNatGateway", "ec2:DeleteNatGateway", "ec2:DescribeNatGateways",
          "ec2:CreateRouteTable", "ec2:DeleteRouteTable", "ec2:DescribeRouteTables",
          "ec2:CreateRoute", "ec2:DeleteRoute", "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable", "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup", "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress", "ec2:RevokeSecurityGroupEgress",
          "ec2:DescribeAvailabilityZones", "ec2:DescribeAccountAttributes",
          "ec2:CreateTags", "ec2:DeleteTags", "ec2:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Sid    = "EKS"
        Effect = "Allow"
        Action = [
          "eks:CreateCluster", "eks:DeleteCluster", "eks:DescribeCluster",
          "eks:ListClusters", "eks:UpdateClusterConfig", "eks:UpdateClusterVersion",
          "eks:TagResource", "eks:UntagResource", "eks:CreateNodegroup",
          "eks:DeleteNodegroup", "eks:DescribeNodegroup", "eks:ListNodegroups",
          "eks:UpdateNodegroupConfig", "eks:UpdateNodegroupVersion",
          "eks:CreateAddon", "eks:DeleteAddon", "eks:DescribeAddon",
          "eks:UpdateAddon", "eks:ListAddons", "eks:DescribeAddonVersions",
          "eks:CreateAccessEntry", "eks:DeleteAccessEntry",
          "eks:DescribeAccessEntry", "eks:UpdateAccessEntry"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAM"
        Effect = "Allow"
        Action = [
          "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:ListRoles",
          "iam:UpdateRole", "iam:UpdateAssumeRolePolicy",
          "iam:AttachRolePolicy", "iam:DetachRolePolicy",
          "iam:ListAttachedRolePolicies", "iam:ListRolePolicies",
          "iam:PassRole", "iam:TagRole", "iam:UntagRole",
          "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile", "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile", "iam:CreatePolicy",
          "iam:DeletePolicy", "iam:GetPolicy", "iam:GetPolicyVersion",
          "iam:CreatePolicyVersion", "iam:DeletePolicyVersion",
          "iam:ListPolicyVersions", "iam:TagPolicy",
          "iam:CreateOpenIDConnectProvider", "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider", "iam:ListOpenIDConnectProviders",
          "iam:TagOpenIDConnectProvider"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECR"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken", "ecr:CreateRepository", "ecr:DeleteRepository",
          "ecr:DescribeRepositories", "ecr:ListRepositories",
          "ecr:SetRepositoryPolicy", "ecr:GetRepositoryPolicy",
          "ecr:PutLifecyclePolicy", "ecr:GetLifecyclePolicy",
          "ecr:PutImageScanningConfiguration", "ecr:TagResource", "ecr:UntagResource",
          "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage", "ecr:PutImage", "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart", "ecr:CompleteLayerUpload",
          "ecr:DescribeImages", "ecr:ListImages", "ecr:BatchDeleteImage"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:DeleteLogGroup",
                  "logs:DescribeLogGroups", "logs:PutRetentionPolicy",
                  "logs:TagLogGroup", "logs:ListTagsLogGroup"]
        Resource = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/eks/*"
      }
    ]
  })

  tags = var.default_tags
}

resource "aws_iam_role_policy_attachment" "pipeline" {
  role       = aws_iam_role.pipeline.name
  policy_arn = aws_iam_policy.pipeline.arn
}
