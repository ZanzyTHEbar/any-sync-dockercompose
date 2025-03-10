#!/bin/bash

echo "INFO: $0 start"

# Set file paths
DEST_PATH="./etc"
NETWORK_FILE="/code/storage/docker-generateconfig/network.yml"

echo "INFO: Create directories for all node types"
for NODE_TYPE in node-1 node-2 node-3 filenode coordinator consensusnode; do
    mkdir -p "${DEST_PATH}/any-sync-${NODE_TYPE}"
done

echo "INFO: Create directory for aws credentials ${DEST_PATH}/.aws"
# Create the directory for AWS credentials
mkdir -p "${DEST_PATH}/.aws"

echo "INFO: Configure external listen host"
# Added check for nodes.yml existence
if [ ! -f "/code/storage/docker-generateconfig/nodes.yml" ]; then
    echo "ERROR: /code/storage/docker-generateconfig/nodes.yml not found. Exiting."
    exit 1
fi
python /tmp/setListenIp.py "/code/storage/docker-generateconfig/nodes.yml" "/code/storage/docker-generateconfig/nodesProcessed.yml"

echo "INFO: Create config for clients"
cp "/code/storage/docker-generateconfig/nodesProcessed.yml" "${DEST_PATH}/client.yml"

echo "INFO: Generate network file"
yq eval '. as $item | {"network": $item}' --indent 2 "/code/storage/docker-generateconfig/nodesProcessed.yml" >"${NETWORK_FILE}"

echo "INFO: Generate config files for 3 nodes"
for i in {0..2}; do
    cat \
        "${NETWORK_FILE}" \
        /tmp/etc/common.yml \
        "/code/storage/docker-generateconfig/account${i}.yml" \
        /tmp/etc/node-$((i + 1)).yml \
        >"${DEST_PATH}/any-sync-node-$((i + 1))/config.yml"
done

echo "INFO: Generate config files for coordinator"
cat "${NETWORK_FILE}" /tmp/etc/common.yml "/code/storage/docker-generateconfig/account3.yml" /tmp/etc/coordinator.yml \
    >${DEST_PATH}/any-sync-coordinator/config.yml
echo "INFO: Generate config files for filenode"
cat "${NETWORK_FILE}" /tmp/etc/common.yml "/code/storage/docker-generateconfig/account4.yml" /tmp/etc/filenode.yml \
    >${DEST_PATH}/any-sync-filenode/config.yml
echo "INFO: Generate config files for consensusnode"
cat "${NETWORK_FILE}" /tmp/etc/common.yml "/code/storage/docker-generateconfig/account5.yml" /tmp/etc/consensusnode.yml \
    >${DEST_PATH}/any-sync-consensusnode/config.yml

echo "INFO: Copy network file to coordinator directory"
cp "/code/storage/docker-generateconfig/nodesProcessed.yml" "${DEST_PATH}/any-sync-coordinator/network.yml"

echo "INFO: Copy aws credentials config"
cp "/tmp/aws-credentials" "${DEST_PATH}/.aws/credentials"

echo "INFO: Replace variables in config files"
for PLACEHOLDER in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY MINIO_BUCKET S3_ENDPOINT \
    ANY_SYNC_NODE_1_ADDRESSES ANY_SYNC_NODE_1_QUIC_ADDRESSES \
    ANY_SYNC_NODE_2_ADDRESSES ANY_SYNC_NODE_2_QUIC_ADDRESSES \
    ANY_SYNC_NODE_3_ADDRESSES ANY_SYNC_NODE_3_QUIC_ADDRESSES \
    ANY_SYNC_COORDINATOR_ADDRESSES ANY_SYNC_COORDINATOR_QUIC_ADDRESSES \
    ANY_SYNC_FILENODE_ADDRESSES ANY_SYNC_FILENODE_QUIC_ADDRESSES \
    ANY_SYNC_CONSENSUSNODE_ADDRESSES ANY_SYNC_CONSENSUSNODE_QUIC_ADDRESSES \
    MONGO_CONNECT REDIS_URL ANY_SYNC_FILENODE_DEFAULT_LIMIT \
    ANY_SYNC_COORDINATOR_DEFAULT_LIMITS_SPACE_MEMBERS_READ \
    ANY_SYNC_COORDINATOR_DEFAULT_LIMITS_SPACE_MEMBERS_WRITE \
    ANY_SYNC_COORDINATOR_DEFAULT_LIMITS_SHARED_SPACES_LIMIT; do
    perl -i -pe "s|%${PLACEHOLDER}%|${!PLACEHOLDER}|g" \
        "${DEST_PATH}"/.aws/credentials \
        "${NETWORK_FILE}" \
        "${DEST_PATH}"/*/*.yml
done

echo "INFO: fix indent in yml files"
for FILE in $(find ${DEST_PATH}/ -name "*.yml"); do
    yq --inplace --indent=2 $FILE
done

echo "INFO: $0 done"
