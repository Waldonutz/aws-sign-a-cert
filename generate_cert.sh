#!/bin/bash

# Script to generate and retrieve a signed certificate from the subordinate CA

# Configuration variables - modify these to match your environment
AWS_REGION=""  # Change to your AWS region
SUB_CA_ARN=""                # Add your Subordinate CA ARN here, again add root CA if you really want 

# Check if a CSR file was provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <csr_file.csr>"
    exit 1
fi

CSR_FILE=$1

# Check if the CSR file exists
if [ ! -f "$CSR_FILE" ]; then
    echo "Error: CSR file '$CSR_FILE' not found."
    exit 1
fi

# Check if SUB_CA_ARN is set
if [ -z "$SUB_CA_ARN" ]; then
    echo "Error: Subordinate CA ARN is not configured."
    echo "Please edit this script and set the SUB_CA_ARN variable."
    exit 1
fi

# Generate a unique idempotency token
IDEMPOTENCY_TOKEN=$(uuidgen)

echo "Issuing certificate using CSR file: $CSR_FILE"

# Issue the certificate
CERT_RESPONSE=$(aws acm-pca issue-certificate \
  --certificate-authority-arn "$SUB_CA_ARN" \
  --csr "fileb://$CSR_FILE" \
  --signing-algorithm "SHA256WITHRSA" \
  --validity Value=3600,Type="DAYS" \
  --idempotency-token "$IDEMPOTENCY_TOKEN" \
  --region "$AWS_REGION")

# Extract the certificate ARN from the response
CERT_ARN=$(echo $CERT_RESPONSE | grep -o "arn:aws:acm-pca:$AWS_REGION:[0-9]*:certificate-authority/[^\"]*")

if [ -z "$CERT_ARN" ]; then
    echo "Error: Failed to issue certificate. Check your AWS credentials and permissions."
    echo "Response: $CERT_RESPONSE"
    exit 1
fi

echo "Certificate issued successfully."
echo "Certificate ARN: $CERT_ARN"

# Generate the output filename based on the input CSR filename
OUTPUT_FILE="${CSR_FILE%.csr}.crt"

echo "Retrieving the signed certificate..."

# Get the certificate
aws acm-pca get-certificate \
  --certificate-authority-arn "$SUB_CA_ARN" \
  --certificate-arn "$CERT_ARN" \
  --query Certificate \
  --region "$AWS_REGION" \
  --output text > "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "Certificate successfully retrieved and saved to: $OUTPUT_FILE"
else
    echo "Error: Failed to retrieve the certificate."
    exit 1
fi

echo "Process completed successfully."
