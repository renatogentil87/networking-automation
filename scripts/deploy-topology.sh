#!/bin/bash

TOPOLOGY_NAME="network-lab"
TOPOLOGY_FILE="topology.yml"

# Check if topology exists
if sudo containerlab inspect --name $TOPOLOGY_NAME &> /dev/null; then
    echo "✓ Topology '$TOPOLOGY_NAME' already deployed"
    echo "✓ Skipping topology deployment"

    # Verify all containers are running
    EXPECTED_CONTAINERS=4
    RUNNING_CONTAINERS=$(sudo docker ps --filter "name=clab-$TOPOLOGY_NAME" --format "{{.Names}}" | wc -l)

    if [ "$RUNNING_CONTAINERS" -ne "$EXPECTED_CONTAINERS" ]; then
        echo "⚠ Warning: Expected $EXPECTED_CONTAINERS containers, found $RUNNING_CONTAINERS"
        echo "⚠ Redeploying topology..."
        sudo containerlab destroy --topo $TOPOLOGY_FILE --cleanup
        sudo containerlab deploy --topo $TOPOLOGY_FILE
    fi
else
    echo "✗ Topology '$TOPOLOGY_NAME' not found"
    echo "→ Deploying topology..."
    sudo containerlab deploy --topo $TOPOLOGY_FILE

    echo "→ Waiting for containers to initialize..."
    sleep 30

    echo "✓ Topology deployed successfully"
fi

# Verify deployment
sudo containerlab inspect --name $TOPOLOGY_NAME
