#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Check if Secure Boot is enabled
if [ "$SECURE_BOOT" != "true" ]; then
    echo "Secure Boot is disabled. Skipping setup."
    exit 0
fi

echo "Setting up UEFI Secure Boot..."

# Check for required tools
check_dependencies() {
    local missing_tools=()
    
    for tool in sbsigntool openssl; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "ERROR: Missing required tools for Secure Boot:"
        printf '  %s\n' "${missing_tools[@]}"
        echo "Install with: sudo apt install sbsigntool openssl"
        exit 1
    fi
}

# Create SecureBoot directory
mkdir -p "$(dirname "$SECURE_BOOT_KEY")"

# Generate certificates if they don't exist
if [ ! -f "$SECURE_BOOT_KEY" ] || [ ! -f "$SECURE_BOOT_CERT" ]; then
    echo "Generating Secure Boot certificates..."
    
    # Generate private key
    openssl genrsa -out "$SECURE_BOOT_KEY" 2048
    
    # Generate certificate (valid for 10 years)
    openssl req -new -x509 -key "$SECURE_BOOT_KEY" -out "$SECURE_BOOT_CERT" -days 3650 \
        -subj "/CN=Ubuilt Secure Boot Database/OU=Ubuilt/O=Ubuilt Project/L=Unknown/C=US" \
        -config <(
            echo '[req]'
            echo 'distinguished_name = req_distinguished_name'
            echo 'x509_extensions = v3_req'
            echo '[req_distinguished_name]'
            echo '[v3_req]'
            echo 'basicConstraints = CA:FALSE'
            echo 'keyUsage = digitalSignature, keyEncipherment'
            echo 'extendedKeyUsage = codeSigning'
            echo 'subjectKeyIdentifier = hash'
        )
    
    echo "Database certificate generated: $SECURE_BOOT_CERT"
fi

# Generate enrollment certificates if they don't exist
if [ ! -f "$SECURE_BOOT_ENROLLMENT_KEY" ] || [ ! -f "$SECURE_BOOT_ENROLLMENT_CERT" ]; then
    echo "Generating Secure Boot enrollment certificates..."
    
    # Generate enrollment private key
    openssl genrsa -out "$SECURE_BOOT_ENROLLMENT_KEY" 2048
    
    # Generate enrollment certificate
    openssl req -new -x509 -key "$SECURE_BOOT_ENROLLMENT_KEY" -out "$SECURE_BOOT_ENROLLMENT_CERT" -days 3650 \
        -subj "/CN=Ubuilt Secure Boot Key Exchange Key/OU=Ubuilt/O=Ubuilt Project/L=Unknown/C=US" \
        -config <(
            echo '[req]'
            echo 'distinguished_name = req_distinguished_name'
            echo 'x509_extensions = v3_req'
            echo '[req_distinguished_name]'
            echo '[v3_req]'
            echo 'basicConstraints = CA:FALSE'
            echo 'keyUsage = digitalSignature, keyEncipherment'
            echo 'extendedKeyUsage = codeSigning'
            echo 'subjectKeyIdentifier = hash'
        )
    
    echo "Enrollment certificate generated: $SECURE_BOOT_ENROLLMENT_CERT"
fi

# Display certificate information
echo ""
echo "Secure Boot certificates generated:"
echo "Database certificate: $SECURE_BOOT_CERT"
echo "Enrollment certificate: $SECURE_BOOT_ENROLLMENT_CERT"

# Save certificate information to file
cat > "$SECURE_BOOT_DIR/certificateinfo.txt" << EOF
Ubuilt UEFI Secure Boot Certificate Information
===============================================

Generated on: $(date)
Build Directory: $WORK

Certificates:
- Database Certificate: $SECURE_BOOT_CERT
- Enrollment Certificate: $SECURE_BOOT_ENROLLMENT_CERT

To enroll these certificates in your system's UEFI:

1. Convert to .der format:
   openssl x509 -in "$SECURE_BOOT_CERT" -outform DER -out "$SECURE_BOOT_DIR/db.der"
   openssl x509 -in "$SECURE_BOOT_ENROLLMENT_CERT" -outform DER -out "$SECURE_BOOT_DIR/KEK.der"

2. Enroll using your system's UEFI setup or mokutil:
   sudo mokutil --import "$SECURE_BOOT_DIR/db.der"
   sudo mokutil --import "$SECURE_BOOT_DIR/KEK.der"

3. Reboot and follow the prompts to enroll the keys

Notes:
- These certificates are specific to this build
- Keep them safe for future ISO updates
- The same certificates can be reused for multiple builds
EOF

echo ""
echo "Certificate information saved to: $SECURE_BOOT_DIR/certificateinfo.txt"
echo ""
echo "To enroll these certificates in your system's UEFI:"
echo "1. Convert to .der format:"
echo "   openssl x509 -in \"$SECURE_BOOT_CERT\" -outform DER -out \"$SECURE_BOOT_DIR/db.der\""
echo "   openssl x509 -in \"$SECURE_BOOT_ENROLLMENT_CERT\" -outform DER -out \"$SECURE_BOOT_DIR/KEK.der\""
echo ""
echo "2. Enroll using your system's UEFI setup or mokutil:"
echo "   sudo mokutil --import \"$SECURE_BOOT_DIR/db.der\""
echo "   sudo mokutil --import \"$SECURE_BOOT_DIR/KEK.der\""
echo ""

echo "Secure Boot setup completed successfully!"
echo "The script continues in 3 seconds..."

sleep 3
