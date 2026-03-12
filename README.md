# Amazon GuardDuty Multi-Region Protection Plan Configuration

## Problem This Solves

**Amazon GuardDuty is not enabled in your organization, or protection plans (S3, EKS, Malware, RDS, Lambda, Runtime Monitoring) are not configured across all regions.**

This solution enables Amazon GuardDuty (if needed) and configures protection plan settings across multiple AWS regions for your delegated administrator account and all member accounts.

## What This Does vs What Amazon GuardDuty Does

**Amazon GuardDuty** = AWS managed threat detection service that continuously monitors AWS accounts and workloads for malicious activity and unauthorized behavior

**This Solution** = Automates the configuration of GuardDuty protection plans across multiple regions, enabling or disabling specific threat detection capabilities for different AWS resource types

> **Important:** GuardDuty detects potential threats, but you are responsible for reviewing findings, investigating alerts, and taking appropriate remediation actions. Enabling protection plans is one component of a comprehensive security strategy.

## Security Responsibilities

**AWS Responsibility:**
- Operating and maintaining the GuardDuty threat detection service
- Analyzing AWS CloudTrail, VPC Flow Logs, and DNS logs for threats
- Updating threat intelligence feeds
- Generating security findings

**Customer Responsibility:**
- Configuring which GuardDuty protection plans to enable
- Reviewing and responding to GuardDuty findings
- Implementing remediation actions for detected threats
- Managing delegated administrator and member account relationships
- Configuring finding notifications and integrations

## Prerequisites

✅ You are logged into the **delegated administrator account** (or can configure one)

That's it! The solution can:
- Enable GuardDuty in each region if not already enabled
- Configure protection plans across all specified regions
- Apply settings to all member accounts

## Quick Start (Console)

### 1. Log into Delegated Admin Account

Go to AWS Console in your Amazon GuardDuty delegated administrator account

### 2. Download Template

Download `template.yaml` from this repository

### 3. Deploy CloudFormation Stack

1. Go to **CloudFormation** console
2. Click **Create stack** → **With new resources**
3. Choose **Upload a template file**
4. Upload `template.yaml`
5. Click **Next**

### 4. Configure Stack

**Stack name:** `gd-config`

**Regions:** Comma-separated list of regions (default includes all AWS regions)
- Default: All regions enabled
- Custom example: `us-east-1,us-west-2,eu-west-1`

**Protection Plans:** Choose ENABLED or DISABLED for each:

**Common Configurations:**

**All protection plans (default):**
- Leave all settings as default (ENABLED)

**Base GuardDuty only:**
- Set ALL protection plans to DISABLED

**Only S3 protection:**
- EnableS3: ENABLED
- All others: DISABLED

**Only Malware protection:**
- EnableMalware: ENABLED
- All others: DISABLED

### 5. Acknowledge and Create

1. Click **Next** through remaining screens
2. Check **I acknowledge that AWS CloudFormation might create IAM resources**
3. Click **Submit**

### 6. Wait for Completion

Stack typically shows `CREATE_COMPLETE` in ~2 minutes

### 7. View Results

Go to **Outputs** tab to see configuration results for each region

## Available Protection Plans

| Parameter | What It Does | Threats Detected |
|-----------|--------------|------------------|
| `EnableS3` | Monitor S3 bucket access patterns | Unusual API calls, data exfiltration attempts, compromised credentials accessing S3 |
| `EnableEKS` | Monitor EKS cluster audit logs | Unauthorized cluster access, suspicious Kubernetes API activity |
| `EnableMalware` | Scan EC2/ECS for malware | Malicious files, trojans, ransomware, cryptocurrency miners |
| `EnableRDS` | Monitor RDS login attempts | Brute force attacks, suspicious login patterns, compromised credentials |
| `EnableLambda` | Monitor Lambda network activity | Suspicious outbound connections, data exfiltration via Lambda |
| `EnableRuntime` | Monitor runtime behavior (requires sub-features below) | Runtime anomalies across compute resources |
| `EnableEKSRuntime` | Monitor EKS pod/container runtime | Container escape attempts, suspicious process execution |
| `EnableECSRuntime` | Monitor ECS Fargate runtime | Anomalous Fargate task behavior, unauthorized network connections |
| `EnableEC2Runtime` | Monitor EC2 instance runtime | Suspicious process execution, privilege escalation attempts |

> **Note:** Disabling protection plans reduces threat detection coverage and may leave specific resource types unmonitored. Evaluate your security requirements before disabling any protection plan.

## Regions

By default, the template configures all AWS regions. To customize, provide a comma-separated list of regions in the `Regions` parameter.

## Update Configuration

1. Go to CloudFormation console
2. Select `gd-config` stack
3. Click **Update**
4. Choose **Use current template**
5. Modify parameters (e.g., disable Malware protection or change regions)
6. Click through and **Submit**

## Security and Risk Considerations

### IAM Permissions
This solution requires IAM permissions including GuardDuty API access and `iam:CreateServiceLinkedRole` scoped to the GuardDuty service-linked role. Review the IAM policy in `template.yaml` before deployment.

### Encryption in Transit
All communications with AWS services use HTTPS/TLS encryption. The AWS SDK and CLI encrypt all API calls by default.

### Access Logging
Enable AWS CloudTrail in your delegated administrator account to log all GuardDuty API operations. Review CloudTrail logs to audit when detectors were created or updated, which protection plans were changed, and changes to member account configurations.

### Operational Risks
- Deployment processes each region sequentially. If the Lambda function times out, some regions may not be configured.
- Changes to protection plans affect all member accounts in the organization.
- Disabling protection plans stops threat detection for those resource types.

### Cost
GuardDuty pricing varies based on data volume analyzed, number of events, and enabled features. See the [Amazon GuardDuty pricing page](https://aws.amazon.com/guardduty/pricing/) for details and use the [AWS Pricing Calculator](https://calculator.aws) to estimate costs for your usage patterns.

## License

MIT License - see [LICENSE](LICENSE) file for details.
