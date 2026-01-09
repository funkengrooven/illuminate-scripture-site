# IAM User Setup for CI/CD Pipeline

## Create IAM User

### Step 1: Create User
1. Go to AWS Console → IAM → Users → Create user
2. **User name**: `bible-apps-cicd` (or similar)
3. **Access type**: ✅ Programmatic access (Access key - Programmatic access)
4. **AWS Management Console access**: ❌ Not needed

### Step 2: Attach Policies
Create a custom policy with minimal required permissions:

#### Option A: Use Existing AWS Managed Policies (Simpler)
Attach these managed policies:
- `AmazonS3FullAccess`
- `CloudFrontFullAccess`

#### Option B: Custom Policy (More Secure - Recommended)
Create a custom policy with these permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3BucketAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:GetBucketVersioning"
            ],
            "Resource": [
                "arn:aws:s3:::illuminate-scripture-site-staging",
                "arn:aws:s3:::illuminate-scripture-site-staging/*",
                "arn:aws:s3:::illuminate-scripture-site-production",
                "arn:aws:s3:::illuminate-scripture-site-production/*"
            ]
        },
        {
            "Sid": "CloudFrontAccess",
            "Effect": "Allow",
            "Action": [
                "cloudfront:CreateInvalidation",
                "cloudfront:GetInvalidation",
                "cloudfront:ListInvalidations"
            ],
            "Resource": [
                "arn:aws:cloudfront::*:distribution/E1CS4TSY1GCKGO",
                "arn:aws:cloudfront::*:distribution/E3E96925SWVM14"
            ]
        }
    ]
}
```

### Step 3: Security Best Practices

#### Add Conditions (Optional but Recommended)
Add IP restrictions if GitHub Actions uses consistent IPs:

```json
{
    "Condition": {
        "IpAddress": {
            "aws:SourceIp": [
                "192.30.252.0/22",
                "185.199.108.0/22",
                "140.82.112.0/20"
            ]
        }
    }
}
```

#### Add Time-based Access (Optional)
Restrict access to business hours if desired:

```json
{
    "Condition": {
        "DateGreaterThan": {
            "aws:CurrentTime": "2024-01-01T00:00:00Z"
        }
    }
}
```

### Step 4: Create Access Keys
1. After creating the user, go to **Security credentials** tab
2. Click **Create access key**
3. Choose **Application running outside AWS**
4. Add description: "GitHub Actions CI/CD Pipeline"
5. **Save both Access Key ID and Secret Access Key**

### Step 5: Test the User
Test the credentials locally first:

```bash
# Configure AWS CLI with new user
aws configure --profile cicd-user
# Enter the new Access Key ID and Secret Access Key

# Test S3 access
aws s3 ls s3://illuminate-scripture-site-staging --profile cicd-user

# Test CloudFront access
aws cloudfront list-invalidations --distribution-id E1CS4TSY1GCKGO --profile cicd-user
```

## Security Recommendations

### ✅ Do:
- Use least privilege principle
- Rotate access keys regularly (every 90 days)
- Monitor usage in CloudTrail
- Use resource-specific ARNs in policies
- Add MFA for sensitive operations (if needed)

### ❌ Don't:
- Use root account credentials
- Give broader permissions than needed
- Share credentials in code or logs
- Use long-lived credentials without rotation

## GitHub Secrets Configuration

Once you have the new credentials, add to GitHub:

```
AWS_ACCESS_KEY_ID=AKIA... (new IAM user key)
AWS_SECRET_ACCESS_KEY=... (new IAM user secret)
STAGING_BUCKET_NAME=illuminate-scripture-site-staging
STAGING_CLOUDFRONT_ID=E1CS4TSY1GCKGO
PRODUCTION_BUCKET_NAME=illuminate-scripture-site-production
PRODUCTION_CLOUDFRONT_ID=E3E96925SWVM14
PRODUCTION_DOMAIN=d3ivjxr85vv1sw.cloudfront.net
```

## Monitoring & Maintenance

### CloudTrail Monitoring
Monitor these API calls:
- `s3:PutObject`, `s3:DeleteObject`
- `cloudfront:CreateInvalidation`

### Regular Maintenance
- Review access logs monthly
- Rotate keys every 90 days
- Update policies as infrastructure changes
- Remove unused permissions

This setup provides secure, minimal access for your CI/CD pipeline while following AWS security best practices.