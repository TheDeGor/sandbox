#!/usr/bin/env bash

source ./instances.raw
echo "---" >inventory/inventory.yaml
echo -e "${ENV}:\n  hosts:" >> inventory/inventory.yaml
n=0
for i in "${INSTANCES[@]}"
do
  echo -e "    instance${n}:" >> inventory/inventory.yaml
  echo -e "      ansible_host: $(gcloud compute instances describe $i --zone=${ZONE} --format=json | jq '.networkInterfaces[0].accessConfigs[0].natIP')" >> inventory/inventory.yaml
  echo -e "      ansible_ssh_private_key_file: ${KEY_PATH}" >> inventory/inventory.yaml
  n=$((n+1))
  # or do whatever with individual element of the array
done