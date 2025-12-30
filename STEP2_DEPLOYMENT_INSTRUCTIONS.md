# Step 2 Deployment Instructions - Source Account

This document provides instructions for deploying Step 2 in the **klaviyo-org** account (905418394749), which is the Management/Payer Account that will send CUR data to the Data Collection Account.

## Prerequisites

- Access to **klaviyo-org** account (905418394749)
- AWS CLI configured with appropriate credentials
- CloudFormation permissions in the source account

## Quick Start

### Option 1: Using the Deployment Script

1. **Authenticate to klaviyo-org account**
   ```bash
   # Use your preferred authentication method
   # Example: saml2aws login --role <your-role-for-klaviyo-org>
   ```

2. **Run the deployment script**
   ```bash
   ./deploy_cudos_step2.sh
   ```

3. **Follow the prompts**
   - The script will verify you're in the correct account
   - Confirm deployment when prompted
   - Wait ~5 minutes for stack creation

### Option 2: Manual CloudFormation Deployment

1. **Navigate to CloudFormation Console**
   - Go to: https://console.aws.amazon.com/cloudformation/home?region=us-east-1
   - Make sure you're in the **klaviyo-org** account (905418394749)
   - Region: **us-east-1**

2. **Create Stack**
   - Click "Create stack" → "With new resources (standard)"
   - Choose "Template is ready"
   - Template source: "Amazon S3 URL"
   - Template URL: `https://aws-managed-cost-intelligence-dashboards.s3.amazonaws.com/cfn/cid-cfn.yml`
   - Click "Next"

3. **Specify Stack Details**
   - Stack name: `CID-DataExports-Source`
   - Parameters:
     - **DestinationAccountId**: `145023124830` (klaviyo-finops)
     - **ManageCUR2**: `yes`
     - Leave other parameters as default unless you need Cost Optimization Hub or FOCUS exports
   - Click "Next"

4. **Configure Stack Options**
   - Tags (optional):
     - Key: `Project`, Value: `CUDOS`
     - Key: `ManagedBy`, Value: `Manual`
     - Key: `DestinationAccount`, Value: `145023124830`
   - Click "Next"

5. **Review and Create**
   - Review all settings
   - Check "I acknowledge that AWS CloudFormation might create IAM resources"
   - Click "Create stack"

6. **Wait for Completion**
   - Stack creation takes ~5 minutes
   - Status will change from `CREATE_IN_PROGRESS` to `CREATE_COMPLETE`
   - Check for any errors in the Events tab

## What This Does

This stack will:
- Create AWS Data Export (CUR 2.0) in the source account
- Configure S3 bucket replication to send data to the Data Collection Account
- Set up necessary IAM roles and policies for data replication

## Important Notes

1. **Data Delivery**: First CUR data delivery takes 24-72 hours. You can proceed with Step 3 deployment, but dashboards will be empty until data arrives.

2. **Historical Data Backfill**: To request historical data (up to 36 months), create an AWS Support Case from the **klaviyo-org** account:
   - Service: Billing
   - Category: Other Billing Questions
   - Subject: Backfill Data
   - Body: "Please can you backfill the data in DataExport named 'cid-cur2' for last [X] months."

3. **Multiple Source Accounts**: If you have multiple Management/Payer Accounts, repeat this step for each one.

## Verification

After deployment, verify:
- Stack status is `CREATE_COMPLETE`
- No errors in CloudFormation Events tab
- AWS Data Exports console shows the new export (may take a few minutes)

## Next Steps

After Step 2 completes:
1. Wait 24-72 hours for first data delivery (or proceed immediately)
2. Deploy Step 3 in the Data Collection Account (145023124830) to create dashboards
3. Optionally request historical data backfill via AWS Support

## Troubleshooting

- **Access Denied**: Ensure you have CloudFormation and CUR permissions in the source account
- **Stack Creation Failed**: Check CloudFormation Events tab for specific error messages
- **Export Not Appearing**: Wait a few minutes and check AWS Data Exports console

