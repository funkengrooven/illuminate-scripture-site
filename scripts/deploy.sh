#!/bin/bash

# Bible Apps Website Deployment Script
# Usage: ./scripts/deploy.sh [staging|production]

set -e

ENVIRONMENT=${1:-staging}
REGION="us-east-1"

echo "🚀 Deploying Bible Apps Website to $ENVIRONMENT..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️  jq is not installed. Installing...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    else
        sudo apt-get update && sudo apt-get install -y jq
    fi
fi

# Validate environment
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    echo -e "${RED}❌ Environment must be 'staging' or 'production'${NC}"
    exit 1
fi

# Set domain based on environment
if [[ "$ENVIRONMENT" == "production" ]]; then
    DOMAIN="bibleapps.com"  # Replace with your actual domain
    STACK_NAME="bible-apps-production"
else
    DOMAIN="staging.bibleapps.com"  # Replace with your actual staging domain
    STACK_NAME="bible-apps-staging"
fi

echo -e "${YELLOW}📋 Configuration:${NC}"
echo "  Environment: $ENVIRONMENT"
echo "  Domain: $DOMAIN"
echo "  Stack: $STACK_NAME"
echo "  Region: $REGION"
echo ""

# Build the application
echo -e "${YELLOW}🔨 Building application...${NC}"
npm ci
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build completed successfully${NC}"

# Deploy CloudFormation stack
echo -e "${YELLOW}☁️  Deploying infrastructure...${NC}"

aws cloudformation deploy \
    --template-file infrastructure/cloudformation.yml \
    --stack-name $STACK_NAME \
    --parameter-overrides \
        DomainName=$DOMAIN \
        Environment=$ENVIRONMENT \
    --capabilities CAPABILITY_IAM \
    --region $REGION

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Infrastructure deployment failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Infrastructure deployed successfully${NC}"

# Get stack outputs
echo -e "${YELLOW}📊 Getting deployment information...${NC}"

BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
    --output text)

DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontDistributionId`].OutputValue' \
    --output text)

WEBSITE_URL=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
    --output text)

echo "  S3 Bucket: $BUCKET_NAME"
echo "  CloudFront ID: $DISTRIBUTION_ID"
echo "  Website URL: $WEBSITE_URL"
echo ""

# Upload files to S3
echo -e "${YELLOW}📤 Uploading files to S3...${NC}"

aws s3 sync out/ s3://$BUCKET_NAME \
    --delete \
    --cache-control "public, max-age=31536000" \
    --exclude "*.html" \
    --region $REGION

# Upload HTML files with shorter cache
aws s3 sync out/ s3://$BUCKET_NAME \
    --delete \
    --cache-control "public, max-age=0, must-revalidate" \
    --include "*.html" \
    --region $REGION

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ S3 upload failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Files uploaded to S3 successfully${NC}"

# Invalidate CloudFront cache
echo -e "${YELLOW}🔄 Invalidating CloudFront cache...${NC}"

INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id $DISTRIBUTION_ID \
    --paths "/*" \
    --query 'Invalidation.Id' \
    --output text)

echo "  Invalidation ID: $INVALIDATION_ID"

# Wait for invalidation to complete (optional)
echo -e "${YELLOW}⏳ Waiting for cache invalidation to complete...${NC}"

aws cloudfront wait invalidation-completed \
    --distribution-id $DISTRIBUTION_ID \
    --id $INVALIDATION_ID

echo -e "${GREEN}✅ Cache invalidation completed${NC}"

# Final success message
echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${GREEN}🌐 Your website is available at: $WEBSITE_URL${NC}"
echo ""

# Performance check
echo -e "${YELLOW}🔍 Running quick performance check...${NC}"
RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}' $WEBSITE_URL)
echo "  Response time: ${RESPONSE_TIME}s"

if (( $(echo "$RESPONSE_TIME < 2.0" | bc -l) )); then
    echo -e "${GREEN}✅ Performance looks good!${NC}"
else
    echo -e "${YELLOW}⚠️  Response time is a bit slow. Consider optimizing.${NC}"
fi

echo ""
echo -e "${GREEN}🚀 Deployment complete! Happy coding!${NC}"