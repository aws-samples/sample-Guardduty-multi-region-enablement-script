# Example Configuration

This file shows example configurations for different use cases.

## Minimal Configuration (Cost-Conscious)

Enable only essential protection plans:

```bash
REGIONS=("us-east-1" "us-west-2")

ENABLE_S3="ENABLED"
ENABLE_K8S="DISABLED"
ENABLE_MALWARE="DISABLED"
ENABLE_RDS="ENABLED"
ENABLE_LAMBDA="ENABLED"
ENABLE_RUNTIME="DISABLED"
ENABLE_EKS_RUNTIME="DISABLED"
ENABLE_ECS_RUNTIME="DISABLED"
ENABLE_EC2_RUNTIME="DISABLED"
```

**Cost considerations:** Amazon GuardDuty pricing varies based on data volume analyzed, number of events, and enabled features. See the [Amazon GuardDuty pricing page](https://aws.amazon.com/guardduty/pricing/) for details and use the [AWS Pricing Calculator](https://calculator.aws) to estimate costs for your usage patterns.

## Recommended Configuration (Balanced)

Good balance of coverage and cost:

```bash
REGIONS=("us-east-1" "us-west-2" "eu-west-1")

ENABLE_S3="ENABLED"
ENABLE_K8S="ENABLED"
ENABLE_MALWARE="ENABLED"
ENABLE_RDS="ENABLED"
ENABLE_LAMBDA="ENABLED"
ENABLE_RUNTIME="DISABLED"
ENABLE_EKS_RUNTIME="DISABLED"
ENABLE_ECS_RUNTIME="DISABLED"
ENABLE_EC2_RUNTIME="DISABLED"
```

## All Amazon GuardDuty Features Enabled

Enable all protection plans:

> **Note:** Enabling all GuardDuty protection plans provides comprehensive threat detection coverage, but security is a shared responsibility. You must review and respond to GuardDuty findings and implement additional security controls appropriate for your workloads.

```bash
REGIONS=("us-east-1" "us-west-2" "eu-west-1" "ap-southeast-1")

ENABLE_S3="ENABLED"
ENABLE_K8S="ENABLED"
ENABLE_MALWARE="ENABLED"
ENABLE_RDS="ENABLED"
ENABLE_LAMBDA="ENABLED"
ENABLE_RUNTIME="ENABLED"
ENABLE_EKS_RUNTIME="ENABLED"
ENABLE_ECS_RUNTIME="ENABLED"
ENABLE_EC2_RUNTIME="ENABLED"
```

## All AWS Regions

To enable Amazon GuardDuty in all commercial AWS regions:

```bash
REGIONS=(
    "us-east-1" "us-east-2" "us-west-1" "us-west-2"
    "ca-central-1"
    "eu-west-1" "eu-west-2" "eu-west-3" "eu-central-1" "eu-north-1"
    "ap-south-1" "ap-northeast-1" "ap-northeast-2" "ap-northeast-3"
    "ap-southeast-1" "ap-southeast-2"
    "sa-east-1"
)
```

**Note:** Only include regions where your organization has resources.
