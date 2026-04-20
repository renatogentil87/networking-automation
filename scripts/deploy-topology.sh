#!/bin/bash
set -euo pipefail

TOPOLOGY_NAME="network-lab"
TOPOLOGY_FILE="/home/ubuntu/network-lab/topology.yml"
INIT_SCRIPT="/home/ubuntu/network-lab/scripts/init-frr.sh"

echo "======================================"
echo "  Containerlab Deployment Manager"
echo "======================================"

# Validate topology file exists
if [ ! -f "$TOPOLOGY_FILE" ]; then
    echo "✗ ERROR: Topology file not found: $TOPOLOGY_FILE"
    exit 1
fi

echo "✓ Topology file found"

# Check if topology already exists
if sudo containerlab inspect --name "$TOPOLOGY_NAME" &>/dev/null; then
    echo "✓ Topology '$TOPOLOGY_NAME' already exists"

    echo "→ Updating topology..."
    sudo containerlab deploy --topo "$TOPOLOGY_FILE" --reconfigure

else
    echo "→ Topology not found. Deploying fresh environment..."

    # Safe cleanup (ignore errors if nothing exists)
    sudo containerlab destroy --topo "$TOPOLOGY_FILE" --cleanup || true

    sudo containerlab deploy --topo "$TOPOLOGY_FILE" --reconfigure
fi

echo ""
echo "→ Waiting for containers to initialize..."
sleep 10

echo ""
echo "→ Initializing FRR services..."
if [ -f "$INIT_SCRIPT" ]; then
    bash "$INIT_SCRIPT"
else
    echo "✗ WARNING: FRR init script not found: $INIT_SCRIPT"
fi

echo ""
echo "======================================"
echo "  Container Status Check"
echo "======================================"

# Define routers explicitly (clean + deterministic)
ROUTERS=("r1" "r2" "r3" "r4")

for router in "${ROUTERS[@]}"; do
    CONTAINER="clab-${TOPOLOGY_NAME}-${router}"

    if sudo docker ps --format "{{.Names}}" | grep -q "^${CONTAINER}$"; then
        echo "✓ ${router}: container running"

        # Basic FRR check
        if sudo docker exec "$CONTAINER" ps aux | grep -q "[f]rr"; then
            echo "  └─ FRR: running"
        else
            echo "  └─ FRR: NOT detected"
        fi

    else
        echo "✗ ${router}: container NOT running"
    fi
done

echo ""
echo "======================================"
echo "  Verifying Control Plane Readiness"
echo "======================================"

# Optional deeper validation (safe, non-failing)
for router in r2 r4; do
    CONTAINER="clab-${TOPOLOGY_NAME}-${router}"

    echo "→ Checking OSPF readiness on ${router}..."

    if sudo docker exec "$CONTAINER" vtysh -c "show ip ospf neighbor" &>/dev/null; then
        echo "✓ ${router}: OSPF CLI responding"
    else
        echo "⚠ ${router}: OSPF not ready yet"
    fi
done

echo ""
echo "✓ Topology deployment complete"
echo "✓ Ready for Ansible configuration push"