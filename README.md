# AWS Cost Dashboards

This repository contains deployment scripts and documentation for AWS Cloud Intelligence Dashboards, specifically the CUDOS (Cost and Usage Dashboard) dashboard.

## Overview

The AWS Cloud Intelligence Dashboards provide comprehensive cost and usage analytics for your AWS environment. This repository focuses on deploying the CUDOS dashboard in the klaviyo-finops account (145023124830).

## Prerequisites

- AWS CLI configured with appropriate credentials
- Access to klaviyo-finops account (145023124830)
- Access to Source Account(s) for CUR data (typically Management/Payer Account)
- QuickSight account set up in the Data Collection Account

## Repository Contents

- `deploy_cudos_step1.sh` - Step 1: Deploy CUR aggregation destination in Data Collection Account
- `deploy_cudos_step3.sh` - Step 3: Deploy CUDOS dashboard stack
- `deploy_cudos_dashboard.md` - Complete deployment guide with detailed instructions

## Quick Start

### 1. Authenticate to AWS

```bash
# Authenticate to your AWS account using your preferred method
# Example: saml2aws login --role <your-role-arn>
```

### 2. Deploy Step 1 (CUR Aggregation)

```bash
./deploy_cudos_step1.sh
```

This will:
- Create S3 bucket for CUR aggregation
- Set up Athena tables
- Configure replication policies

### 3. Deploy Step 2 (in Source Account)

Deploy the CloudFormation template in your Management/Payer Account with:
- `DestinationAccountId`: `145023124830`
- Select exports to manage

### 4. Deploy Step 3 (Dashboard)

```bash
./deploy_cudos_step3.sh
```

This will deploy the CUDOS dashboard and create QuickSight datasets.

## Account Information

- **Data Collection Account**: klaviyo-finops (145023124830)
- **Likely Source Account**: klaviyo-prod (368154587575)
- **Recommended Region**: us-east-1

## Documentation

For detailed deployment instructions, see:
- [AWS Cloud Intelligence Dashboards Deployment Guide](https://docs.aws.amazon.com/guidance/latest/cloud-intelligence-dashboards/deployment-in-global-regions.html)
- `deploy_cudos_dashboard.md` in this repository

## Notes

- First CUR data delivery takes 24-72 hours
- All stacks must be in the same region to avoid cross-region data transfer charges
- Historical data backfill can be requested via AWS Support Case

