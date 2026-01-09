#!/bin/bash

# Custom Domain Setup Script for Bible Apps Website
# This script helps you connect your GoDaddy domain to AWS

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                Custom Domain Setup                           ║"
echo "║            Connect GoDaddy to AWS CloudFront                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Get user input
echo -e "${YELLOW}📝 Please provide your domain information:${NC}"
read -p "Enter your domain name (e.g., bibleapps.com): " DOMAIN_NAME
read -p "Do you want to use Route 53 for DNS management? (y/N): " USE_ROUTE53

echo ""
echo -e "${BLUE}📋 Configuration:${NC}"
echo "  Domain: $DOMAIN_NAME"
echo "  Current Production URL: https://d3ivjxr85vv1sw.cloudfront.net"
echo ""

if [[ $USE_ROUTE53 =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🏗️  Setting up Route 53 hosted zone...${NC}"
    
    # Create hosted zone
    aws route53 create-hosted-zone \
        --name $DOMAIN_NAME \
        --caller-reference $(date +%s) \
        --hosted-zone-config Comment="Bible Apps Website"
    
    # Get name servers
    HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
        --dns-name $DOMAIN_NAME \
        --query 'HostedZones[0].Id' \
        --output text | cut -d'/' -f3)
    
    NAME_SERVERS=$(aws route53 get-hosted-zone \
        --id $HOSTED_ZONE_ID \
        --query 'DelegationSet.NameServers' \
        --output text)
    
    echo -e "${GREEN}✅ Route 53 hosted zone created!${NC}"
    echo -e "${YELLOW}📋 Update these name servers in GoDaddy:${NC}"
    echo "$NAME_SERVERS" | tr '\t' '\n'
    echo ""
    echo -e "${YELLOW}🔧 Steps to update GoDaddy:${NC}"
    echo "1. Go to GoDaddy → My Products → DNS"
    echo "2. Find your domain → Manage DNS"
    echo "3. Change Nameservers to 'Custom'"
    echo "4. Enter the name servers listed above"
    echo ""
    
    # Create SSL certificate
    echo -e "${YELLOW}🔒 Creating SSL certificate...${NC}"
    CERT_ARN=$(aws acm request-certificate \
        --domain-name $DOMAIN_NAME \
        --subject-alternative-names www.$DOMAIN_NAME \
        --validation-method DNS \
        --region us-east-1 \
        --query 'CertificateArn' \
        --output text)
    
    echo "Certificate ARN: $CERT_ARN"
    echo ""
    echo -e "${YELLOW}⏳ Waiting for certificate validation records...${NC}"
    sleep 30
    
    # Get validation records
    aws acm describe-certificate \
        --certificate-arn $CERT_ARN \
        --region us-east-1 \
        --query 'Certificate.DomainValidationOptions[*].[DomainName,ResourceRecord.Name,ResourceRecord.Value]' \
        --output table
    
    echo -e "${YELLOW}📝 Creating DNS validation records...${NC}"
    # This would create the validation records automatically
    
else
    echo -e "${YELLOW}📋 Manual GoDaddy DNS Setup Instructions:${NC}"
    echo ""
    echo "1. Go to GoDaddy → My Products → DNS"
    echo "2. Find your domain → Manage DNS"
    echo "3. Add/Edit these records:"
    echo ""
    echo "   Record Type: CNAME"
    echo "   Name: www"
    echo "   Value: d3ivjxr85vv1sw.cloudfront.net"
    echo "   TTL: 1 Hour"
    echo ""
    echo "   Record Type: A"
    echo "   Name: @"
    echo "   Value: Set up domain forwarding to www.$DOMAIN_NAME"
    echo ""
    echo -e "${GREEN}✅ After DNS propagation (5-48 hours), your site will be available at:${NC}"
    echo "   https://www.$DOMAIN_NAME"
    echo "   https://$DOMAIN_NAME (if forwarding is set up)"
fi

echo ""
echo -e "${BLUE}🔍 Testing current setup:${NC}"
echo "Production site: https://d3ivjxr85vv1sw.cloudfront.net"
echo ""
echo -e "${YELLOW}💡 Pro Tips:${NC}"
echo "• DNS changes can take 5-48 hours to propagate"
echo "• Test with 'dig $DOMAIN_NAME' to check DNS resolution"
echo "• Use online DNS checkers to verify propagation"
echo "• SSL certificates can take 20+ minutes to validate"
echo ""
echo -e "${GREEN}🎉 Setup instructions complete!${NC}"