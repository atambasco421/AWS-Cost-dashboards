#!/bin/bash
# Step 3: Deploy CUDOS Dashboard in Data Collection Account
# Account: klaviyo-finops (145023124830)

set -e

ACCOUNT_ID="145023124830"
REGION="${AWS_REGION:-us-east-1}"
STACK_NAME="Cloud-Intelligence-Dashboards"

echo "=========================================="
echo "CUDOS Dashboard - Step 3 Deployment"
echo "=========================================="
echo "Account: ${ACCOUNT_ID}"
echo "Region: ${REGION}"
echo "Stack: ${STACK_NAME}"
echo ""

# Check AWS credentials
echo "Checking AWS credentials..."
aws sts get-caller-identity || {
    echo "ERROR: AWS credentials not configured or expired"
    echo "Please authenticate first"
    exit 1
}

# Get QuickSight username
echo ""
echo "Enter your QuickSight username:"
echo "  (Find it in QuickSight console > person icon in top right)"
read -p "QuickSight Username: " QUICKSIGHT_USERNAME

if [ -z "$QUICKSIGHT_USERNAME" ]; then
    echo "ERROR: QuickSight username is required"
    exit 1
fi

# CloudFormation template URL
TEMPLATE_URL="https://aws-managed-cost-intelligence-dashboards.s3.amazonaws.com/cfn/cid-cfn.yml"

echo ""
echo "Deploying CloudFormation stack..."
echo "Template: ${TEMPLATE_URL}"
echo ""

# Deploy stack
aws cloudformation create-stack \
    --region "${REGION}" \
    --stack-name "${STACK_NAME}" \
    --template-url "${TEMPLATE_URL}" \
    --parameters \
        ParameterKey=PrerequisitesQ1,ParameterValue=yes \
        ParameterKey=PrerequisitesQ2,ParameterValue=yes \
        ParameterKey=QuickSightUserName,ParameterValue="${QUICKSIGHT_USERNAME}" \
        ParameterKey=CurVersion,ParameterValue=2.0 \
        ParameterKey=DeployCUDOS,ParameterValue=yes \
        ParameterKey=DeployCID,ParameterValue=no \
        ParameterKey=DeployKPI,ParameterValue=no \
    --capabilities CAPABILITY_NAMED_IAM \
    --tags \
        Key=Project,Value=CUDOS \
        Key=ManagedBy,Value=Manual

echo ""
echo "Stack creation initiated. Waiting for completion..."
echo "This may take ~15 minutes..."

aws cloudformation wait stack-create-complete \
    --region "${REGION}" \
    --stack-name "${STACK_NAME}"

echo ""
echo "✅ Step 3 Complete!"
echo ""
echo "Getting dashboard URLs..."

# Get stack outputs
aws cloudformation describe-stacks \
    --region "${REGION}" \
    --stack-name "${STACK_NAME}" \
    --query 'Stacks[0].Outputs' \
    --output table

echo ""
echo "Note: Dashboards will be empty until CUR data arrives (24-72 hours)"
echo "You can request a backfill via AWS Support Case if needed"

