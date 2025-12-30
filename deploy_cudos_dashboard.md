# CUDOS Dashboard Deployment Guide
## Account: klaviyo-finops (145023124830)

Based on [AWS Cloud Intelligence Dashboards Deployment Guide](https://docs.aws.amazon.com/guidance/latest/cloud-intelligence-dashboards/deployment-in-global-regions.html)

## Prerequisites

1. **Authenticate to AWS**: Make sure you're logged into the klaviyo-finops account (145023124830)
   ```bash
   saml2aws login --role Okta-FinOps-prod/anthony.tambasco@klaviyo.com
   # Or use your preferred authentication method
   ```

2. **Choose a Region**: Select a region for deployment (recommend us-east-1 for lowest costs)
   - All stacks must be in the same region to avoid cross-region data transfer charges

3. **Identify Source Accounts**: Determine which accounts will send CUR data
   - Typically the Management/Payer Account(s)
   - May include multiple linked accounts

## Deployment Steps

### Step 1: [Data Collection Account] Create Destination For CUR Aggregation

**Account**: klaviyo-finops (145023124830) - This is your Data Collection Account

1. **Launch Stack**: Use the CloudFormation template for Step 1
   - Template URL: https://aws-managed-cost-intelligence-dashboards.s3.amazonaws.com/cfn/cid-cfn.yml
   - Or use the Launch Stack button from the AWS documentation

2. **Stack Parameters**:
   - `DestinationAccountId`: `145023124830` (your Data Collection Account)
   - `Manage CUR 2.0`: `yes`
   - `SourceAccountId`: Enter comma-separated list of source account IDs
     - If deploying in Management/Payer Account, include `145023124830` as first element
   - Optional: Enable Cost Optimization Hub and FOCUS exports if needed

3. **Create Stack**: 
   - Stack name: `CID-DataExports-Destination`
   - Acknowledge IAM resource creation
   - Wait 5-15 minutes for completion

### Step 2: [Source Account(s)] Create CUR 2.0 and Replication

**For each Source Account** (typically Management/Payer Account):

1. **Launch Stack**: Use the CloudFormation template for Step 2
   - Same template URL as Step 1

2. **Stack Parameters**:
   - `Stack name`: `CID-DataExports-Source`
   - `DestinationAccountId`: `145023124830` (Data Collection Account)
   - Select exports to manage (must match Step 1 configuration)

3. **Create Stack**: 
   - Acknowledge IAM resource creation
   - Wait ~5 minutes for completion
   - Repeat for other Source Accounts

**Note**: First data delivery takes 24-72 hours. You can proceed with Step 3, but dashboards will be empty until data arrives.

### Step 3: [Data Collection Account] Deploy Dashboards

**Account**: klaviyo-finops (145023124830)

#### 3.1 - Prepare Amazon QuickSight

1. **Sign up for QuickSight** (if not already done):
   - Navigate to QuickSight in AWS Console
   - Select the same region as Step 1
   - Choose authentication method:
     - `Use AWS IAM Identity Center` (recommended for production/sharing)
     - `Use IAM federated identities & QuickSight-managed users` (quick start, but cannot change later)
   - Create account with unique name
   - Configure SPICE capacity: ~40GB (auto-purchase recommended)

2. **Find QuickSight Username**:
   - Open QuickSight console
   - Click person icon in top right corner
   - Copy your username (needed for Step 3.2)

#### 3.2 - Deploy CUDOS Dashboard

**Option A: CloudFormation (Recommended)**

1. **Launch Stack**:
   - Template URL: https://aws-managed-cost-intelligence-dashboards.s3.amazonaws.com/cfn/cid-cfn.yml
   - Or use Launch Stack button from documentation

2. **Stack Parameters**:
   - `Stack name`: `Cloud-Intelligence-Dashboards`
   - `QuickSightUserName`: Your QuickSight username from Step 3.1
   - `Prerequisites`: Answer `yes` to both prerequisite questions
   - `Dashboards`: Select CUDOS (and optionally CID, KPI)
   - `CurVersion`: `2.0` (for CUR 2.0)

3. **Create Stack**:
   - Acknowledge IAM resource creation
   - Wait ~15 minutes for completion
   - Check stack outputs for dashboard URLs

**Option B: Command Line (Alternative)**

```bash
# Install cid-cmd tool
pip3 install --upgrade cid-cmd

# Deploy CUDOS Dashboard
cid-cmd deploy --dashboard-id cudos-v5

# Follow the deployment wizard prompts
```

## Post-Deployment

1. **Backfill Historical Data** (Optional):
   - Create AWS Support Case from Source Account
   - Request backfill for up to 36 months of historical data
   - Service: Billing
   - Category: Other Billing Questions

2. **Verify Data**:
   - Wait 24-48 hours for first data delivery
   - Check QuickSight Datasets for errors
   - Manually refresh datasets if needed

3. **Access Dashboards**:
   - Use URLs from CloudFormation stack outputs
   - Dashboards will populate once data is available

## Troubleshooting

- **No data after 24-48 hours**: Check QuickSight datasets for errors, verify CUR data in S3
- **"No export named cid-DataExports-ReadAccessPolicyARN found"**: Step 1 stack not deployed correctly
- **SPICE capacity errors**: Increase SPICE capacity in QuickSight settings

## Next Steps

- Deploy additional dashboards (CID, KPI)
- Deploy CORA dashboard
- Deploy Compute Optimizer Dashboard
- Deploy Trusted Advisor Organizational (TAO) Dashboard

