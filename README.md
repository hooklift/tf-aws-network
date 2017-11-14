# Hooklift AWS network

In order to work on network changes you first need to pull the current state by running: 

terraform remote config -backend=s3 \
-backend-config="bucket=hooklift-infra" \
-backend-config="key=aws/network/terraform.tfstate" \
-backend-config="region=us-east-1"
