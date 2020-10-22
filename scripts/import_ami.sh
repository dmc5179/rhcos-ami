#!/bin/bash

# RedHat CoreOS Version
RHCOS_VERSION="4.5.6"

# S3 Bucket where the RHCOS VMDK is located
S3BUCKET="mybucket"

# S3 ARN Prefix (Different for GovCloud and other private regions"
S3ARN="arn:aws:s3"

# Path to RHCOS VMDK in the S3 Bucket
OBJECT_PATH="rhcos-${RHCOS_VERSION}-x86_64-aws.x86_64.vmdk"

# Extra options for the AWS command line line custom API endpoints
#AWS_OPTS='--endpoint-url '

cat << EOF > containers.json
{
    "Description": "Red Hat CoreOS ${RHCOS_VERSION} VMDK",
    "Format": "VMDK",
    "UserBucket": {
        "S3Bucket": "${S3BUCKET}",
        "S3Key": "${OBJECT_PATH}"
    }
}
EOF

RET=$(aws ${AWS_OPTS} ec2 import-snapshot --description "Red Hat CoreOS ${RHCOS_VERSION} VMDK" --disk-container "file://./containers.json")
IMPORT_ID=$( echo "${RET}" | jq -r '.ImportTaskId')

IMPORT_STATUS='active'
COUNTER=100
until [[ ${IMPORT_STATUS} == "completed" || ${COUNTER} -eq 0 ]]
do
  echo "Waiting for snapshot import to complete: ${COUNTER} tries remaining"
  IMPORT_STATUS=$(aws ${AWS_OPTS} ec2 describe-import-snapshot-tasks --import-tasks-ids ${IMPORT_ID} | jq -r '.ImportSnapshotTasks.SnapshotTaskDetail.Status')
  let COUNTER-=1
  sleep 10
done

if [[ ! ${IMPORT_STATUS} == 'completed' ]]
then
  echo "Snapshot import failed, aborting"
  exit 1
fi

SNAP_ID=$(aws ${AWS_OPTS} ec2 describe-import-snapshot-tasks --import-tasks-ids ${IMPORT_ID} | jq -r '.ImportSnapshotTasks.SnapshotTaskDetail.SnapshotId')

aws ${AWS_OPTS} ec2 register-image --name "Red Hat CoreOS ${RHCOS_VERSION}" \
    --block-device-mappings \
"[{\"DeviceName\": \"/dev/xvda\",\"Ebs\":{\"VolumeSize\":16,\"VolumeType\":\"gp2\",\"DeleteOnTermination\":true,\"SnapshotId\":\"snap-01dc35d89af6144e0\"}}]" \
    --root-device-name '/dev/xvda' --architecture x86_64 \
    --description "Red Hat CoreOS ${RHCOS_VERSION}" \
    --virtualization-type hvm --ena-support
