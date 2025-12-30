#!/bin/bash
# Step 2: Deploy CUR 2.0 and Replication in Source Account
# Account: klaviyo-org (905418394749) - Management/Payer Account

set -e

ACCOUNT_ID="905418394749"
DESTINATION_ACCOUNT_ID="145023124830"
REGION="${AWS_REGION:-us-east-1}"
STACK_NAME="CID-DataExports-Source"

echo "=========================================="
echo "CUDOS Dashboard - Step 2 Deployment"
echo "=========================================="
echo "Source Account: ${ACCOUNT_ID} (klaviyo-org)"
echo "Destination Account: ${DESTINATION_ACCOUNT_ID} (klaviyo-finops)"
echo "Region: ${REGION}"
echo "Stack: ${STACK_NAME}"
echo ""

# Check AWS credentials
echo "Checking AWS credentials..."
aws sts get-caller-identity || {
    echo "ERROR: AWS credentials not configured or expired"
    echo "Please authenticate first to the klaviyo-org account (905418394749)"
    exit 1
}

# Verify we're in the correct account
CURRENT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
if [ "$CURRENT_ACCOUNT" != "$ACCOUNT_ID" ]; then
    echo "WARNING: Current account ($CURRENT_ACCOUNT) does not match target account ($ACCOUNT_ID)"
    echo "Expected: klaviyo-org (905418394749)"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# CloudFormation template URL
TEMPLATE_URL="https://aws-managed-cost-intelligence-dashboards.s3.amazonaws.com/cfn/cid-cfn.yml"

echo ""
echo "This will deploy CUR 2.0 and replication to send data to the Data Collection Account."
echo ""
echo "Configuration:"
echo "  - Destination Account: ${DESTINATION_ACCOUNT_ID} (klaviyo-finops)"
echo "  - Manage CUR 2.0: yes"
echo ""

read -p "Continue with deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 1
fi

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
        ParameterKey=DestinationAccountId,ParameterValue="${DESTINATION_ACCOUNT_ID}" \
        ParameterKey=ManageCUR2,ParameterValue=yes \
    --capabilities CAPABILITY_NAMED_IAM \
    --tags \
        Key=Project,Value=CUDOS \
        Key=ManagedBy,Value=Manual \
        Key=DestinationAccount,Value="${DESTINATION_ACCOUNT_ID}"

echo ""
echo "Stack creation initiated. Waiting for completion..."
echo "This may take ~5 minutes..."

aws cloudformation wait stack-create-complete \
    --region "${REGION}" \
    --stack-name "${STACK_NAME}"

echo ""
echo "✅ Step 2 Complete!"
echo ""
echo "Important Notes:"
echo "1. First CUR data delivery will take 24-72 hours"
echo "2. You can proceed with Step 3 deployment, but dashboards will be empty until data arrives"
echo "3. To request historical data backfill, create an AWS Support Case from this account:"
echo "   - Service: Billing"
echo "   - Category: Other Billing Questions"
echo "   - Subject: Backfill Data"
echo "   - Request backfill for DataExport named 'cid-cur2'"
echo ""
echo "Next step: Deploy Step 3 in the Data Collection Account (145023124830)"

