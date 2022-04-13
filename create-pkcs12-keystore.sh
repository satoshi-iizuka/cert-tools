#! /bin/bash

if [[ $# < 3 ]]; then
cat <<EOL
Missing parameters. Use:

  $(basename $0) <store> <name> <pem file> [<key file>] [<keystore pass>]

  e.g.
  $(basename $0) my-ca.p12 my-ca my-ca.pem my-ca.key password

NOTE: Java would not be able to process keystore file without password properly.
  
EOL
   exit 1
fi

STORE_FILE=$1
STORE_PASS=$5
BAG_NAME=$2
CERT_FILE=$3
KEY_FILE=$4

if [ -z "$KEY_FILE" ]; then
  OPENSSL_OPTS="-nokeys"
else
  OPENSSL_OPTS="-inkey ${KEY_FILE}"
fi

if [ -z "$STORE_PASS" ]; then
  OPENSSL_OPTS="${OPENSSL_OPTS} -keypbe NONE -certpbe NONE"
fi

cat <<EOL
keystore: $STORE_FILE
password: $STORE_PASS
bag name: $BAG_NAME
certificate file: $CERT_FILE
key file: $KEY_FILE
EOL

openssl pkcs12 -export \
  -name "${BAG_NAME}" \
  -in "${CERT_FILE}" \
  -out "${STORE_FILE}" \
  -passout "pass:${STORE_PASS}" \
  ${OPENSSL_OPTS}

openssl pkcs12 -info -nokeys -in "${STORE_FILE}" -passin "pass:${STORE_PASS}"

