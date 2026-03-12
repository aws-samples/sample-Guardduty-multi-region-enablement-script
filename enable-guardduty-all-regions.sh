#!/bin/bash
#
# Amazon GuardDuty Multi-Region Configuration Script
# 
# This script updates Amazon GuardDuty protection plans across multiple AWS regions
# for a delegated administrator account and all member accounts.
#
# Prerequisites:
# - AWS CLI configured with Amazon GuardDuty delegated admin credentials
# - GuardDuty already enabled in target regions
# - Member accounts already added to GuardDuty organization
#
# Usage: ./enable-guardduty-all-regions.sh
#

set -e

# ============================================================================
# CONFIGURATION - Edit these values for your organization
# ============================================================================

# Regions to update (add or remove as needed)
REGIONS=("us-east-1" "us-west-2")

# Protection plan settings (ENABLED or DISABLED)
ENABLE_S3="ENABLED"                # S3 data access monitoring
ENABLE_K8S="ENABLED"               # EKS audit logs
ENABLE_MALWARE="ENABLED"           # EC2/ECS malware scanning
ENABLE_RDS="ENABLED"               # RDS login monitoring
ENABLE_LAMBDA="ENABLED"            # Lambda network monitoring
ENABLE_RUNTIME="ENABLED"           # Runtime monitoring (requires sub-features below)
ENABLE_EKS_RUNTIME="ENABLED"       # EKS runtime monitoring
ENABLE_ECS_RUNTIME="ENABLED"       # ECS Fargate runtime monitoring
ENABLE_EC2_RUNTIME="ENABLED"       # EC2 runtime monitoring

# ============================================================================
# VALIDATION
# ============================================================================

validate_status() {
    local value="$1"
    local name="$2"
    if [[ "$value" != "ENABLED" && "$value" != "DISABLED" ]]; then
        echo "Error: $name must be ENABLED or DISABLED, got: $value"
        exit 1
    fi
}

validate_status "$ENABLE_S3" "ENABLE_S3"
validate_status "$ENABLE_K8S" "ENABLE_K8S"
validate_status "$ENABLE_MALWARE" "ENABLE_MALWARE"
validate_status "$ENABLE_RDS" "ENABLE_RDS"
validate_status "$ENABLE_LAMBDA" "ENABLE_LAMBDA"
validate_status "$ENABLE_RUNTIME" "ENABLE_RUNTIME"
validate_status "$ENABLE_EKS_RUNTIME" "ENABLE_EKS_RUNTIME"
validate_status "$ENABLE_ECS_RUNTIME" "ENABLE_ECS_RUNTIME"
validate_status "$ENABLE_EC2_RUNTIME" "ENABLE_EC2_RUNTIME"

for r in "${REGIONS[@]}"; do
    if ! [[ "$r" =~ ^[a-z]{2}-[a-z]+-[0-9]{1}$ ]]; then
        echo "Error: Invalid region format: $r"
        exit 1
    fi
done

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

echo "Updating Amazon GuardDuty configuration across regions..."

for REGION in "${REGIONS[@]}"; do
    echo ""
    echo "=== Processing region: $REGION ==="
    
    # Get detector ID
    DETECTOR_ID=$(aws guardduty list-detectors --region "$REGION" --query 'DetectorIds[0]' --output text)
    
    if [ "$DETECTOR_ID" = "None" ] || [ -z "$DETECTOR_ID" ]; then
        echo "No detector found in $REGION, skipping..."
        continue
    fi
    
    echo "Detector ID: $DETECTOR_ID"
    
    # Update detector configuration
    aws guardduty update-detector \
        --detector-id "$DETECTOR_ID" \
        --region "$REGION" \
        --finding-publishing-frequency FIFTEEN_MINUTES \
        --features "[
            {\"Name\":\"S3_DATA_EVENTS\",\"Status\":\"$ENABLE_S3\"},
            {\"Name\":\"EKS_AUDIT_LOGS\",\"Status\":\"$ENABLE_K8S\"},
            {\"Name\":\"EBS_MALWARE_PROTECTION\",\"Status\":\"$ENABLE_MALWARE\"},
            {\"Name\":\"RDS_LOGIN_EVENTS\",\"Status\":\"$ENABLE_RDS\"},
            {\"Name\":\"LAMBDA_NETWORK_LOGS\",\"Status\":\"$ENABLE_LAMBDA\"},
            {\"Name\":\"RUNTIME_MONITORING\",\"Status\":\"$ENABLE_RUNTIME\",\"AdditionalConfiguration\":[
                {\"Name\":\"EKS_ADDON_MANAGEMENT\",\"Status\":\"$ENABLE_EKS_RUNTIME\"},
                {\"Name\":\"ECS_FARGATE_AGENT_MANAGEMENT\",\"Status\":\"$ENABLE_ECS_RUNTIME\"},
                {\"Name\":\"EC2_AGENT_MANAGEMENT\",\"Status\":\"$ENABLE_EC2_RUNTIME\"}
            ]}
        ]"
    
    echo "✓ Updated detector in $REGION"
    
    # Update member account configurations
    MEMBER_ACCOUNTS=$(aws guardduty list-members --detector-id "$DETECTOR_ID" --region "$REGION" --query 'Members[?RelationshipStatus==`Enabled`].AccountId' --output text)
    
    if [ -z "$MEMBER_ACCOUNTS" ]; then
        echo "No member accounts found in $REGION"
        continue
    fi
    
    echo "Updating configuration for member accounts..."
    for ACCOUNT_ID in $MEMBER_ACCOUNTS; do
        ERROR_OUTPUT=$(aws guardduty update-member-detectors \
            --detector-id "$DETECTOR_ID" \
            --region "$REGION" \
            --account-ids "$ACCOUNT_ID" \
            --features "[
                {\"Name\":\"S3_DATA_EVENTS\",\"Status\":\"$ENABLE_S3\"},
                {\"Name\":\"EKS_AUDIT_LOGS\",\"Status\":\"$ENABLE_K8S\"},
                {\"Name\":\"EBS_MALWARE_PROTECTION\",\"Status\":\"$ENABLE_MALWARE\"},
                {\"Name\":\"RDS_LOGIN_EVENTS\",\"Status\":\"$ENABLE_RDS\"},
                {\"Name\":\"LAMBDA_NETWORK_LOGS\",\"Status\":\"$ENABLE_LAMBDA\"},
                {\"Name\":\"RUNTIME_MONITORING\",\"Status\":\"$ENABLE_RUNTIME\",\"AdditionalConfiguration\":[
                    {\"Name\":\"EKS_ADDON_MANAGEMENT\",\"Status\":\"$ENABLE_EKS_RUNTIME\"},
                    {\"Name\":\"ECS_FARGATE_AGENT_MANAGEMENT\",\"Status\":\"$ENABLE_ECS_RUNTIME\"},
                    {\"Name\":\"EC2_AGENT_MANAGEMENT\",\"Status\":\"$ENABLE_EC2_RUNTIME\"}
                ]}
            ]" 2>&1) || echo "  ⚠ Failed to update account $ACCOUNT_ID: $ERROR_OUTPUT"
    done
    
    echo "✓ Completed $REGION"
done

echo ""
echo "=== All regions updated ==="
