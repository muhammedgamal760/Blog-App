#!/bin/bash

# Kubernetes deployment script

set -e

echo "🚀 Deploying Blog Application to Kubernetes..."

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Build Docker images (for local deployment)
echo "🔨 Building Docker images..."
cd backend
docker build -t blog-backend:latest .
cd ../frontend
docker build -t blog-frontend:latest .
cd ..

# Apply Kubernetes manifests
echo "📦 Applying Kubernetes manifests..."
kubectl apply -f k8s/mysql-deployment.yaml
echo "⏳ Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s

kubectl apply -f k8s/backend-deployment.yaml
echo "⏳ Waiting for backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend --timeout=120s

kubectl apply -f k8s/frontend-deployment.yaml
echo "⏳ Waiting for frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend --timeout=120s

# Display deployment status
echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Deployment Status:"
kubectl get pods
echo ""
echo "🌐 Services:"
kubectl get services
echo ""
echo "💡 To access the application:"
echo "   Run: kubectl port-forward service/frontend 3000:80"
echo "   Then open: http://localhost:3000"
