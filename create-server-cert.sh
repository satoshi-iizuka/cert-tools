#!/bin/bash

if [[ $# < 3 ]]; then
  cat <<EOL
Missing parameters. Use:

  $(basename $0) <ca-cert> <ca-key> <server-cn>

  e.g.
  $(basename $0) my-ca.pem my-ca.key my-server
  
EOL
  exit 1
fi

CA_CERT="$1"
CA_KEY="$2"
SERVER_CN="$3"
SERVER_KEY="${SERVER_CN}.key"
SERVER_CERT="${SERVER_CN}.pem"
SERVER_CERT_REQ="${SERVER_CN}.csr"

# Generate server key
echo "Generate Server Key"
openssl genrsa \
  -passout "pass:password" \
  -out "${SERVER_KEY}" \
  2048

echo "Removing password from the server private key"
cp ${SERVER_KEY} ${SERVER_KEY}.org
openssl rsa \
  -in "${SERVER_KEY}.org" \
  -passin "pass:password" \
  -out "${SERVER_KEY}"
rm -f "${SERVER_KEY}.org"

# Create server certificate sigining request
echo "Generate server certificate signing request"
openssl req \
  -new \
  -key "${SERVER_KEY}" \
  -out "${SERVER_CERT_REQ}" \
  -subj "/CN=$SERVER_CN"

# Create server certificate extension configuration
cat > "${SERVER_CN}.cnf" <<EOT
authorityKeyIdentifier=keyid,issuer
keyUsage=digitalSignature
extendedKeyUsage=serverAuth
subjectAltName=@alt_names

[alt_names]
DNS.1=localhost
DNS.2=${SERVER_CN}
IP.1=127.0.0.1
EOT

# Sing the request
echo "Signing server cert request"
openssl x509 -req \
  -in "${SERVER_CERT_REQ}" \
  -sha256 \
  -days 1825 \
  -CA "${CA_CERT}" \
  -CAkey "${CA_KEY}" \
  -CAcreateserial \
  -out "${SERVER_CERT}" \
  -extfile "${SERVER_CN}.cnf"

rm -f "${SERVER_CERT_REQ}" "${SERVER_CN}.cnf"

openssl x509 \
  -in "${SERVER_CERT}" \
  -text \
  -noout
