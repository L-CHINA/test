#!/bin/bash
################################################################################
# Step 1: Setup Harbor Proxy Projects
# This script creates proxy cache projects in Harbor for various registries
################################################################################

set -e

# Harbor Configuration
HARBOR_URL="${HARBOR_URL:-https://internal.demo.io}"
HARBOR_USER="${HARBOR_USER:-admin}"
HARBOR_PASSWORD="${HARBOR_PASSWORD:-Harbor1234}"

echo "=========================================="
echo "Step 1: Setting up Harbor Proxy Projects"
echo "=========================================="

# Function to create proxy project
create_proxy_project() {
    local PROJECT_NAME=$1
    local REGISTRY_URL=$2
    local REGISTRY_TYPE=$3
    
    echo ""
    echo "Creating proxy project: ${PROJECT_NAME}"
    echo "  Registry: ${REGISTRY_URL}"
    echo "  Type: ${REGISTRY_TYPE}"
    
    curl -k -X POST "${HARBOR_URL}/api/v2.0/projects" \
        -u "${HARBOR_USER}:${HARBOR_PASSWORD}" \
        -H "Content-Type: application/json" \
        -d "{\n            \"project_name\": \"${PROJECT_NAME}\",
            \"public\": true,
            \"registry_id\": null,
            \"metadata\": {
                \"public\": \"true\"
            }
        }" || echo "Project ${PROJECT_NAME} may already exist"
    
    echo "✓ Project ${PROJECT_NAME} created/verified"
}

# Create Docker Hub proxy
create_proxy_project "dockerhub-proxy" "https://registry-1.docker.io" "docker-hub"

# Create registry.k8s.io proxy (most important for kubeadm)
create_proxy_project "k8s-proxy" "https://registry.k8s.io" "docker-registry"

# Create gcr.io proxy
create_proxy_project "gcr-proxy" "https://gcr.io" "google-gcr"

# Create quay.io proxy
create_proxy_project "quay-proxy" "https://quay.io" "quay"

echo ""
echo "=========================================="
echo "✓ Harbor proxy projects setup completed!"
echo "=========================================="
echo ""
echo "Next step: Run step2-configure-containerd.sh"