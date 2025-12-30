#!/bin/bash
# Step 1: Deploy CUR Aggregation Destination in Data Collection Account
# Account: klaviyo-finops (145023124830)

set -e

ACCOUNT_ID="145023124830"
REGION="${AWS_REGION:-us-east-1}"
STACK_NAME="CID-DataExports-Destination"

echo "=========================================="
echo "CUDOS Dashboard - Step 1 Deployment"
echo "=========================================="
echo "Account: ${ACCOUNT_ID}"
echo "Region: ${REGION}"
echo "Stack: ${STACK_NAME}"
echo ""

# Check AWS credentials
echo "Checking AWS credentials..."
aws sts get-caller-identity || {
    echo "ERROR: AWS credentials not configured or expired"
    echo "Please authenticate first:"
    echo "  saml2aws login --role Okta-FinOps-prod/anthony.tambasco@klaviyo.com"
    exit 1
}

# Verify we're in the correct account
CURRENT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
if [ "$CURRENT_ACCOUNT" != "$ACCOUNT_ID" ]; then
    echo "WARNING: Current account ($CURRENT_ACCOUNT) does not match target account ($ACCOUNT_ID)"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get source account IDs
echo ""
echo "Enter Source Account IDs (comma-separated):"
echo "  - Default: 905418394749 (klaviyo-org - Management/Payer Account)"
echo "  - If this is the Management/Payer Account, include ${ACCOUNT_ID} as first account"
echo "  - Example: 145023124830,905418394749"
read -p "Source Account IDs [905418394749]: " SOURCE_ACCOUNTS

# Use default if empty
if [ -z "$SOURCE_ACCOUNTS" ]; then
    SOURCE_ACCOUNTS="905418394749"
    echo "Using default source account: ${SOURCE_ACCOUNTS}"
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
        ParameterKey=DestinationAccountId,ParameterValue="${ACCOUNT_ID}" \
        ParameterKey=ManageCUR2,ParameterValue=yes \
        ParameterKey=SourceAccountId,ParameterValue="${SOURCE_ACCOUNTS}" \
    --capabilities CAPABILITY_NAMED_IAM \
    --tags \
        Key=Project,Value=CUDOS \
        Key=ManagedBy,Value=Manual

echo ""
echo "Stack creation initiated. Waiting for completion..."
echo "This may take 5-15 minutes..."

aws cloudformation wait stack-create-complete \
    --region "${REGION}" \
    --stack-name "${STACK_NAME}"

echo ""
echo "✅ Step 1 Complete!"
echo ""
echo "Next steps:"
echo "1. Deploy Step 2 in Source Account(s)"
echo "2. Wait 24-72 hours for first data delivery (or proceed with Step 3)"
echo "3. Deploy Step 3 to create dashboards"

