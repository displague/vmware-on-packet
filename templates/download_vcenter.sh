#!/bin/bash

SSH_PRIVATE_KEY='${ssh_private_key}'

s3_boolean=`echo "${s3_boolean}" | awk '{print tolower($0)}'`

# TODO: This should probably not be hidden in the download_vcenter.sh
cat <<EOF >/$HOME/.ssh/esxi_key
$SSH_PRIVATE_KEY
EOF
chmod 0400 /$HOME/.ssh/esxi_key
# END TODO
echo "Set SSH config to not do StrictHostKeyChecking"
cat <<EOF >/$HOME/.ssh/config
Host *
    StrictHostKeyChecking no
EOF
chmod 0400 /$HOME/.ssh/config

BASE_DIR="/$HOME/bootstrap"

mkdir -p $BASE_DIR
cd $BASE_DIR
if [ $s3_boolean = "false" ]; then
  echo "USING GCS"
  gcloud auth activate-service-account --key-file=$HOME/bootstrap/gcp_storage_reader.json
  gsutil cp gs://${gcs_bucket_name}/${vcenter_iso_name} .
  gsutil cp gs://${gcs_bucket_name}/vsanapiutils.py .
  gsutil cp gs://${gcs_bucket_name}/vsanmgmtObjects.py .
else
  echo "USING S3"
  curl -LO https://dl.min.io/client/mc/release/linux-amd64/mc
  chmod +x mc
  mv mc /usr/local/bin/
  mc config host add s3 ${s3_url} ${s3_access_key} ${s3_secret_key}
  mc cp s3/${s3_bucket_name}/${vcenter_iso_name} .
  mc cp s3/${s3_bucket_name}/vsanapiutils.py .
  mc cp s3/${s3_bucket_name}/vsanmgmtObjects.py .
fi
mount $BASE_DIR/${vcenter_iso_name} /mnt/
