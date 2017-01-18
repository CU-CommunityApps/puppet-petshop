#!/bin/bash

# Encrypt whole files using a KMS key.
# The encrypted file content will be saved in a file with suffix ".encrypted"
# added to it. The user/role that runs this script must have appropriate privs
# to use the given key.
# This script will refuse files with length >= 4KB since that is the limit
# for direct KMS encryption.

KMS_KEY_ID=4c044060-5160-4738-9c7b-009e7fc2c104
MAX_BYTES=4096
AWS_REGION=us-east-1

for FILE in "$@"
do
  BYTES=`wc -c < $FILE`
  echo "Processing $FILE - $BYTES bytes"
  if [$BYTES -ge $MAX_BYTES ]; then
    echo "Skipping $FILE because it is too big to encrypt directly with KMS (4KB)."
  else
    aws kms encrypt --key-id $KMS_KEY_ID --plaintext fileb://$FILE --output text --query CiphertextBlob --region $AWS_REGION | base64 --decode > $FILE.encrypted
  fi
done

