# GitHub Actions Deployment Guide

## Step-by-Step Setup

### 1. **Create GitHub Repository**

```bash
# Initialize git in your project
git init
git add .
git commit -m "Initial commit: Bible Apps website"

# Create repository on GitHub (via web interface)
# Then connect your local repo:
git remote add origin https://github.com/YOUR_USERNAME/illuminate-scripture-site.git
git branch -M main
git push -u origin main

# Create develop branch for staging
git checkout -b develop
git push -u origin develop
```

### 2. **Set Up AWS Infrastructure**

#### A. Create AWS Account & Get Credentials
1. Sign up at [aws.amazon.com](https://aws.amazon.com)
2. Create an IAM user with programmatic access
3. Attach these policies:
   - `AmazonS3FullAccess`
   - `CloudFrontFullAccess`
   - `AmazonRoute53FullAccess`
   - `AWSCertificateManagerFullAccess`

#### B. Deploy Infrastructure
```bash
# Deploy staging environment
aws cloudformation deploy \
  --template-file infrastructure/cloudformation.yml \
  --stack-name bible-apps-staging \
  --parameter-overrides \
    DomainName=staging.yourdomain.com \
    Environment=staging \
  --capabilities CAPABILITY_IAM \
  --region us-east-1

# Deploy production environment
aws cloudformation deploy \
  --template-file infrastructure/cloudformation.yml \
  --stack-name bible-apps-production \
  --parameter-overrides \
    DomainName=yourdomain.com \
    Environment=production \
  --capabilities CAPABILITY_IAM \
  --region us-east-1
```

### 3. **Configure GitHub Secrets**

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

```
AWS_ACCESS_KEY_ID=your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_key_here
STAGING_BUCKET_NAME=staging.yourdomain.com-staging
STAGING_CLOUDFRONT_ID=E1234567890ABC
PRODUCTION_BUCKET_NAME=yourdomain.com-production  
PRODUCTION_CLOUDFRONT_ID=E0987654321XYZ
PRODUCTION_DOMAIN=yourdomain.com
```

#### How to get the values:
```bash
# Get bucket names and CloudFront IDs from CloudFormation
aws cloudformation describe-stacks --stack-name bible-apps-staging --query 'Stacks[0].Outputs'
aws cloudformation describe-stacks --stack-name bible-apps-production --query 'Stacks[0].Outputs'
```

### 4. **Test the Pipeline**

#### Staging Deployment:
```bash
# Make a change and push to develop
git checkout develop
echo "Testing staging deployment" >> README.md
git add .
git commit -m "Test staging deployment"
git push origin develop
```

#### Production Deployment:
```bash
# Merge to main for production
git checkout main
git merge develop
git push origin main
```

### 5. **Verify Deployment**

Check these things after deployment:

✅ **GitHub Actions**: Go to Actions tab, verify builds are green
✅ **S3 Buckets**: Check files are uploaded correctly
✅ **CloudFront**: Verify cache invalidation completed
✅ **Website**: Visit your URLs and test functionality
✅ **SSL**: Ensure HTTPS is working properly

### 6. **Domain Setup (Optional)**

If you have a custom domain:

1. **Buy domain** (Route 53, Namecheap, etc.)
2. **Update CloudFormation** with your actual domain
3. **Configure DNS** to point to CloudFront
4. **Wait for SSL certificate** validation (can take 20+ minutes)

### 7. **Development Workflow**

```bash
# Daily development workflow:
git checkout develop
# Make your changes in Kiro
git add .
git commit -m "Add new feature"
git push origin develop
# → Automatically deploys to staging

# When ready for production:
git checkout main
git merge develop
git push origin main
# → Automatically deploys to production
```

## Troubleshooting

### Common Issues:

**Build Fails:**
- Check GitHub Actions logs
- Verify all dependencies are in package.json
- Ensure TypeScript compiles without errors

**Deployment Fails:**
- Verify AWS credentials in GitHub secrets
- Check IAM permissions
- Ensure bucket names match exactly

**SSL Certificate Issues:**
- DNS validation can take 20+ minutes
- Ensure domain ownership is verified
- Check Route 53 hosted zone configuration

**CloudFront Cache Issues:**
- Cache invalidation takes 5-15 minutes
- Use browser incognito mode for testing
- Check CloudFront distribution settings

### Useful Commands:

```bash
# Check deployment status
aws cloudformation describe-stacks --stack-name bible-apps-production

# Manual cache invalidation
aws cloudfront create-invalidation --distribution-id YOUR_ID --paths "/*"

# Check S3 bucket contents
aws s3 ls s3://your-bucket-name --recursive

# Test website performance
curl -w "@curl-format.txt" -o /dev/null -s https://yourdomain.com
```

## Cost Monitoring

Expected monthly costs:
- **S3**: $1-5 (storage + requests)
- **CloudFront**: $1-10 (data transfer)
- **Route 53**: $0.50 (hosted zone)
- **GitHub Actions**: Free (2,000 minutes/month)
- **Total**: ~$3-16/month

Set up AWS billing alerts to monitor costs!

## Next Steps

Once this is working:
1. Add custom domain
2. Set up monitoring with CloudWatch
3. Add performance testing
4. Consider adding automated tests
5. Set up error tracking (Sentry, etc.)

Happy deploying! 🚀