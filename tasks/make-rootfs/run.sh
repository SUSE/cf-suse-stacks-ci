#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

SUFFIX="${STACKS_SUFFIX:-}"
STACK_NAME="opensuse42"

src-ci/tasks/common/start-docker.sh

make -C src

versioned_stack_filename="out/${STACK_NAME}${SUFFIX}-$(cat version/number).tar.gz"
mv src/${STACK_NAME}.tar.gz "${versioned_stack_filename}"

versioned_receipt_filename="out/${STACK_NAME}${SUFFIX}-$(cat version/number).receipt.txt"
echo "Rootfs SHASUM: $(sha1sum "$versioned_stack_filename" | awk '{print $1}')" > "$versioned_receipt_filename"
echo "" >> "$versioned_receipt_filename"
cat src/cflinuxfs2/${STACK_NAME}_zypper.out >> "$versioned_receipt_filename"

# No need to diff the rootfs shasum, that will always be different
diff -u \
    <(tail -n +2 "receipt/${STACK_NAME}${SUFFIX}-$(cat receipt/version).receipt.txt") \
    <(tail -n +2 "$versioned_receipt_filename") \
    > "out/${STACK_NAME}${SUFFIX}-$(cat version/number).receipt.diff" \
    || true
