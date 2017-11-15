# Terraform AWS Network module

It creates a VPC with private and public subnets spread out in multiple availability zones.

terraform remote config -backend=s3 \
-backend-config="bucket=hooklift-infra" \
-backend-config="key=aws/network/terraform.tfstate" \
-backend-config="region=us-east-1"
