#!/bin/bash

TOPOLOGY_NAME="network-lab"
TOPOLOGY_FILE="/home/ubuntu/network-lab/topology.yml"

# Check if topology file exists
if [ ! -f "$TOPOLOGY_FILE" ]; then
    echo "✗ Error: Topology file not found at $TOPOLOGY_FILE"
    exit 1
fi

# Check if topology exists
if sudo containerlab inspect --name $TOPOLOGY_NAME &> /dev/null; then
    echo "✓ Topology '$TOPOLOGY_NAME' already deployed"

    # Verify all containers are running
    EXPECTED_CONTAINERS=4
    RUNNING_CONTAINERS=$(sudo docker ps --filter "name=clab-$TOPOLOGY_NAME" --filter "status=running" --format "{{.Names}}" | wc -l)

    if [ "$RUNNING_CONTAINERS" -ne "$EXPECTED_CONTAINERS" ]; then
        echo "⚠ Warning: Expected $EXPECTED_CONTAINERS containers, found $RUNNING_CONTAINERS"
        echo "⚠ Redeploying topology..."
        sudo containerlab destroy --topo $TOPOLOGY_FILE --cleanup
        sudo containerlab deploy --topo $TOPOLOGY_FILE
        echo "→ Waiting for containers to initialize..."
        sleep 15

        # Initialize FRR after redeployment
        echo "→ Initializing FRR services..."
        /home/ubuntu/network-lab/scripts/init-frr.sh
    else
        echo "✓ All containers running"
        # Verify FRR is initialized, reinitialize if needed
        if ! sudo docker exec clab-network-lab-r1 ps aux | grep -q "[b]gpd"; then
            echo "→ FRR not initialized, initializing now..."
            /home/ubuntu/network-lab/scripts/init-frr.sh
        else
            echo "✓ FRR already initialized"
        fi
    fi
else
    echo "✗ Topology '$TOPOLOGY_NAME' not found"
    echo "→ Deploying topology..."
    sudo containerlab destroy --topo $TOPOLOGY_FILE --cleanup 2>/dev/null || true
    sudo containerlab deploy --topo $TOPOLOGY_FILE

    echo "→ Waiting for containers to initialize..."
    sleep 15

    # Initialize FRR after deployment
    echo "→ Initializing FRR services..."
    /home/ubuntu/network-lab/scripts/init-frr.sh

    echo "✓ Topology deployed successfully"
fi

# Final verification
echo ""
echo "Verifying deployment..."
sudo containerlab inspect --name $TOPOLOGY_NAME

echo ""
echo "Verifying FRR services..."
for router in r1 r2 r3 r4; do
    if sudo docker exec clab-network-lab-$router ps aux | grep -q "[b]gpd"; then
        echo "✓ $router: FRR services running"
    else
        echo "✗ $router: FRR services NOT running"
    fi
done
