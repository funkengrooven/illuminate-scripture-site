#!/bin/bash

# Quick Setup Script for Bible Apps Website
# This script will deploy the infrastructure and get you started quickly

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                Bible Apps Website Setup                      ║"
echo "║                Quick Start Deployment                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check prerequisites
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not found. Please install it first:${NC}"
    echo "   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git not found. Please install Git first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Get user input
echo ""
echo -e "${YELLOW}📝 Please provide the following information:${NC}"

read -p "Enter a unique bucket name (e.g., bible-apps-yourname-123): " BUCKET_NAME
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your GitHub repository name (default: bible-apps-website): " REPO_NAME
REPO_NAME=${REPO_NAME:-bible-apps-website}

echo ""
echo -e "${BLUE}📋 Configuration Summary:${NC}"
echo "  Bucket Name: $BUCKET_NAME"
echo "  GitHub: $GITHUB_USERNAME/$REPO_NAME"
echo "  Region: us-east-1"
echo ""

read -p "Continue with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 1
fi

# Deploy staging infrastructure
echo ""
echo -e "${YELLOW}🏗️  Deploying staging infrastructure...${NC}"

aws cloudformation deploy \
    --template-file infrastructure/simple-cloudformation.yml \
    --stack-name bible-apps-staging \
    --parameter-overrides \
        BucketName=$BUCKET_NAME \
        Environment=staging \
    --region us-east-1

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Staging deployment failed${NC}"
    exit 1
fi

# Deploy production infrastructure
echo -e "${YELLOW}🏗️  Deploying production infrastructure...${NC}"

aws cloudformation deploy \
    --template-file infrastructure/simple-cloudformation.yml \
    --stack-name bible-apps-production \
    --parameter-overrides \
        BucketName=$BUCKET_NAME \
        Environment=production \
    --region us-east-1

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Production deployment failed${NC}"
    exit 1
fi

# Get deployment outputs
echo -e "${YELLOW}📊 Getting deployment information...${NC}"

STAGING_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name bible-apps-staging \
    --region us-east-1 \
    --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
    --output text)

STAGING_DISTRIBUTION=$(aws cloudformation describe-stacks \
    --stack-name bible-apps-staging \
    --region us-east-1 \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontDistributionId`].OutputValue' \
    --output text)

STAGING_URL=$(aws cloudformation describe-stacks \
    --stack-name bible-apps-staging \
    --region us-east-1 \
    --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
    --output text)

PRODUCTION_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name bible-apps-production \
    --region us-east-1 \
    --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
    --output text)

PRODUCTION_DISTRIBUTION=$(aws cloudformation describe-stacks \
    --stack-name bible-apps-production \
    --region us-east-1 \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontDistributionId`].OutputValue' \
    --output text)

PRODUCTION_URL=$(aws cloudformation describe-stacks \
    --stack-name bible-apps-production \
    --region us-east-1 \
    --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
    --output text)

# Create GitHub secrets file
echo -e "${YELLOW}🔐 Creating GitHub secrets configuration...${NC}"

cat > github-secrets.txt << EOF
# Add these secrets to your GitHub repository:
# Go to: https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/secrets/actions

AWS_ACCESS_KEY_ID=your_aws_access_key_here
AWS_SECRET_ACCESS_KEY=your_aws_secret_key_here
STAGING_BUCKET_NAME=$STAGING_BUCKET
STAGING_CLOUDFRONT_ID=$STAGING_DISTRIBUTION
PRODUCTION_BUCKET_NAME=$PRODUCTION_BUCKET
PRODUCTION_CLOUDFRONT_ID=$PRODUCTION_DISTRIBUTION
PRODUCTION_DOMAIN=${PRODUCTION_URL#https://}
EOF

# Test build and deploy
echo -e "${YELLOW}🔨 Testing build...${NC}"
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed. Please fix build errors before continuing.${NC}"
    exit 1
fi

# Deploy to staging for initial test
echo -e "${YELLOW}🚀 Deploying to staging for initial test...${NC}"

aws s3 sync out/ s3://$STAGING_BUCKET --delete --region us-east-1
aws cloudfront create-invalidation --distribution-id $STAGING_DISTRIBUTION --paths "/*" --region us-east-1

echo ""
echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo ""
echo -e "${YELLOW}1. Set up GitHub repository:${NC}"
echo "   git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo "   git checkout -b develop"
echo "   git push -u origin develop"
echo ""
echo -e "${YELLOW}2. Add GitHub Secrets:${NC}"
echo "   Go to: https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/secrets/actions"
echo "   Add the secrets from: github-secrets.txt"
echo ""
echo -e "${YELLOW}3. Test your websites:${NC}"
echo "   Staging:    $STAGING_URL"
echo "   Production: $PRODUCTION_URL"
echo ""
echo -e "${YELLOW}4. Development workflow:${NC}"
echo "   - Push to 'develop' branch → deploys to staging"
echo "   - Push to 'main' branch → deploys to production"
echo ""
echo -e "${GREEN}🌐 Your Bible Apps website is now live!${NC}"
echo ""
echo -e "${BLUE}💡 Pro tip: It may take 5-10 minutes for CloudFront to fully propagate.${NC}"
echo -e "${BLUE}    If you see errors initially, wait a few minutes and try again.${NC}"