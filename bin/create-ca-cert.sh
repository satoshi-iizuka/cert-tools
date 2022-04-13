#!/bin/bash

if [[ $# < 1 ]]; then
  cat <<EOL
No CN is specified. Use:

  $(basename $0) <CA-CN>

  e.g.
  $(basename $0) "My Own CA"

EOL
  exit 1
fi

CA_CN=$1
CA_KEY="${CA_CN}.key"
CA_CERT="${CA_CN}.pem"

# Gererate CA Key
echo "Generating CA key"
openssl genrsa \
  -des3 \
  -passout "pass:password" \
  -out ${CA_KEY} \
  4096

echo "Removing password from the private key"
cp "${CA_KEY}" "${CA_KEY}.org"
openssl rsa -in "${CA_KEY}.org" -out "${CA_KEY}" -passin "pass:password"
rm -f "${CA_KEY}.org"

# Create CA Certificate
echo "Creating a CA certificate"
openssl req \
  -x509 \
  -new \
  -nodes \
  -key "${CA_KEY}" \
  -sha256 \
  -days 1825\
  -out "${CA_CERT}" \
  -subj "/C=JP/ST=Tokyo/L=Tokyo/O=Private/CN=${CA_CN}"

openssl x509 -in "${CA_CERT}" -text -noout
