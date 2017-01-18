#!/bin/bash

# Decrypt whole files that have previously been encrypted using a KMS key.
#
# If the input file name has suffix ".encrypted" then the decrypted file name
# will just drop the ".encrypted".
#
# If the input file name does not have suffix ".encrypted", then the decrypted
# contents will be saved as FILENAME.plaintext.

AWS_REGION=us-east-1

for FILE in "$@"
do
  TARGET="$FILE.plaintext"
  if [[ "$FILE" =~ ^.*encrypted$ ]]; then
    TARGET=${FILE/\.encrypted/}
  fi
  echo "Processing $FILE. Decrypting to $TARGET."
  aws kms decrypt --ciphertext-blob fileb://$FILE --output text --query Plaintext --region $AWS_REGION | base64 --decode > $TARGET
done

