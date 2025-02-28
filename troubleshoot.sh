#!/bin/bash
# Kubernetes troubleshooting script for the mini-demo application
# This script helps diagnose and fix common issues with the deployment

# Color definitions for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== KUBERNETES TROUBLESHOOTING TOOL =====${NC}"

# Step 1: Check Minikube status
echo -e "${GREEN}Checking Minikube status...${NC}"
minikube status

# Step 2: Check if namespace exists
echo -e "${GREEN}Checking if mini-demo namespace exists...${NC}"
if kubectl get namespace mini-demo > /dev/null 2>&1; then
    echo "Namespace mini-demo exists"
else
    echo -e "${RED}Namespace mini-demo does not exist. Creating it...${NC}"
    kubectl create namespace mini-demo
fi

# Step 3: Get the current state of all resources in the namespace
echo -e "${GREEN}Listing all resources in mini-demo namespace...${NC}"
echo -e "${YELLOW}Pods:${NC}"
kubectl -n mini-demo get pods -o wide
echo -e "${YELLOW}Deployments:${NC}"
kubectl -n mini-demo get deployments
echo -e "${YELLOW}Services:${NC}"
kubectl -n mini-demo get services
echo -e "${YELLOW}ConfigMaps:${NC}"
kubectl -n mini-demo get configmaps

# Step 4: Check pod logs
echo -e "${GREEN}Checking pod logs for errors...${NC}"
for pod in $(kubectl -n mini-demo get pods --no-headers -o custom-columns=":metadata.name"); do
    echo -e "${BLUE}Logs for ${pod}:${NC}"
    kubectl -n mini-demo logs ${pod} || echo "Unable to get logs"
done

# Step 5: Describe pods for more detailed information
echo -e "${GREEN}Describing pods for detailed information...${NC}"
for pod in $(kubectl -n mini-demo get pods --no-headers -o custom-columns=":metadata.name"); do
    echo -e "${BLUE}Describing ${pod}:${NC}"
    kubectl -n mini-demo describe pod ${pod}
done

# Step 6: Check Docker images
echo -e "${GREEN}Checking Docker images...${NC}"
eval $(minikube docker-env)
docker images | grep mini-k8s-demo

# Step 7: Test Docker image directly
echo -e "${GREEN}Testing Docker image directly...${NC}"
if docker images | grep -q mini-k8s-demo; then
    echo "Running container directly to test..."
    docker run --rm -d --name test-flask-app mini-k8s-demo:latest
    sleep 3
    if [ "$(docker ps -q -f name=test-flask-app 2>/dev/null)" = "" ]; then
        echo -e "${RED}Container failed to start. Checking logs...${NC}"
        docker logs test-flask-app 2>&1 || true
    else
        echo -e "${GREEN}Container started successfully.${NC}"
        echo "Container logs:"
        docker logs test-flask-app
        docker stop test-flask-app
    fi
else
    echo -e "${RED}Docker image mini-k8s-demo:latest not found${NC}"
    echo "You may need to rebuild the image."
fi

# Step 8: Offer common fixes
echo -e "${BLUE}===== COMMON FIXES =====${NC}"
echo "1. Rebuild Docker image with debug output:"
echo "   cd ~/mini-k8s-demo/app"
echo "   eval \$(minikube docker-env)"
echo "   docker build -t mini-k8s-demo:latest ."
echo ""
echo "2. Update deployment to use the new image:"
echo "   kubectl -n mini-demo rollout restart deployment/flask-app"
echo ""
echo "3. Modify timeouts for health checks:"
echo "   kubectl -n mini-demo edit deployment/flask-app"
echo "   # Increase initialDelaySeconds and timeoutSeconds in probes"
echo ""
echo "4. Check for resource constraints:"
echo "   kubectl -n mini-demo describe nodes"
echo ""
echo "5. Fix permissions issues:"
echo "   # Modify Dockerfile to run as non-root user"
echo ""
echo "6. Clear the CrashLoopBackOff state by deleting the pods:"
echo "   kubectl -n mini-demo delete pods --all"
echo ""
echo "7. If all else fails, recreate the deployment:"
echo "   kubectl delete namespace mini-demo"
echo "   cd ~/mini-k8s-demo"
echo "   ./deploy.sh"

echo -e "${BLUE}===== TROUBLESHOOTING COMPLETE =====${NC}"
