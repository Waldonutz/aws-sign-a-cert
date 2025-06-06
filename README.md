# Certificate Generation Tool

This tool automates the process of generating and retrieving signed certificates from a subordinate CA in your AWS Account.

## Prerequisites

1. AWS CLI installed and configured
2. AWS credentials with access to your AWS Account - SSO - Keys - You figure it out
3. Permissions to use the Private CA and Subordinate CA
4. A valid CSR file

## Configuration

Before using the script, you need to configure it with your CA information:

1. Edit the `generate_cert.sh` script
2. Set the `AWS_REGION` variable to your AWS region
3. Set the `SUB_CA_ARN` variable to your Subordinate CA ARN - I don't target the ROOT CA, but you can do this if you're like Maverick

Example configuration:
```bash
AWS_REGION="us-east-1"
SUB_CA_ARN="arn:aws:acm-pca:us-east-1:123456789012:certificate-authority/abcdef12-3456-7890-abcd-ef1234567890"
```

## Usage

```bash
./generate_cert.sh <csr_file.csr>
```

### Example

```bash
./generate_cert.sh device.csr
```

## What the Script Does

1. Validates that a CSR file was provided
2. Issues a certificate using the CSR against the Subordinate CA
3. Retrieves the signed certificate
4. Saves the certificate as a `.crt` file with the same base name as the CSR file

## Certificate Details

- **Signing Algorithm**: SHA256WITHRSA
- **Validity Period**: 3600 days (approximately 10 years)

## Troubleshooting

If you encounter issues:

1. Ensure your AWS credentials are valid and have the necessary permissions
2. Verify that the CSR file exists and is properly formatted
3. Check that you're connected to the correct AWS account
4. Verify that the CA ARN is correctly configured in the script

## Process Flow

1. Client generates and sends CSR file
2. AWS administrator runs this script with the CSR file
3. Script generates and retrieves the signed certificate
4. Administrator sends the resulting .crt file back to the client
