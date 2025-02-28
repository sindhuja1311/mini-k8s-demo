#!/bin/bash
# Fix for Flask and Werkzeug dependency issue

# Navigate to the app directory
cd ~/mini-k8s-demo/app

# Update requirements.txt with pinned versions
echo "# Updated dependencies with compatible versions
Flask==2.2.3
Werkzeug==2.2.3
" > requirements.txt

# Update Dockerfile to ensure clean installation
cat > Dockerfile << 'EOL'
# Use Python 3.9 slim image as base
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements file first for better layer caching
COPY requirements.txt .

# Install dependencies with explicit upgrade of pip
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Expose port
EXPOSE 5000

# Run Flask application
CMD ["python", "app.py"]
EOL

# Build the updated Docker image
echo "Building updated Docker image with compatible dependencies..."
eval $(minikube docker-env)
docker build -t mini-k8s-demo:latest .

# Restart the deployment
echo "Restarting Kubernetes deployment..."
kubectl -n mini-demo rollout restart deployment/flask-app

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl -n mini-demo rollout status deployment/flask-app

# Show pod status
echo "Current pod status:"
kubectl -n mini-demo get pods

echo "Fix applied. Check if the pods are now running correctly."
echo "To see the logs, run: kubectl -n mini-demo logs -l app=flask-app"
