# Manual Step 1 Deployment Instructions

Since the CLI role doesn't have CloudFormation permissions, use the AWS Console to deploy Step 1.

## Steps

1. **Navigate to CloudFormation Console**
   - Go to: https://console.aws.amazon.com/cloudformation/home?region=us-east-1
   - Make sure you're in the **klaviyo-finops** account (145023124830)
   - Region: **us-east-1**

2. **Create Stack**
   - Click "Create stack" → "With new resources (standard)"
   - Choose "Template is ready"
   - Template source: "Amazon S3 URL"
   - Template URL: `https://aws-managed-cost-intelligence-dashboards.s3.amazonaws.com/cfn/cid-cfn.yml`
   - Click "Next"

3. **Specify Stack Details**
   - Stack name: `CID-DataExports-Destination`
   - Parameters:
     - **DestinationAccountId**: `145023124830`
     - **ManageCUR2**: `yes`
     - **SourceAccountId**: `905418394749` (klaviyo-org - Management/Payer Account, or comma-separated list if multiple)
     - Leave other parameters as default unless you need Cost Optimization Hub or FOCUS exports
   - Click "Next"

4. **Configure Stack Options**
   - Tags (optional):
     - Key: `Project`, Value: `CUDOS`
     - Key: `ManagedBy`, Value: `Manual`
   - Click "Next"

5. **Review and Create**
   - Review all settings
   - Check "I acknowledge that AWS CloudFormation might create IAM resources"
   - Click "Create stack"

6. **Wait for Completion**
   - Stack creation takes 5-15 minutes
   - Status will change from `CREATE_IN_PROGRESS` to `CREATE_COMPLETE`
   - Check for any errors in the Events tab

## Next Steps

After Step 1 completes:
1. Deploy Step 2 in the Source Account (368154587575 - klaviyo-prod)
2. Wait 24-72 hours for first data delivery (or proceed with Step 3)
3. Deploy Step 3 to create the dashboards

