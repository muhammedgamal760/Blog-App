#!/bin/bash

# Helm deployment script

set -e

echo "🚀 Deploying Blog Application with Helm..."

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm first."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Validate Helm chart
echo "🔍 Validating Helm chart..."
helm lint helm/blog-app

# Install or upgrade the release
RELEASE_NAME=${1:-my-blog}
NAMESPACE=${2:-default}

echo "📦 Installing Helm release: $RELEASE_NAME in namespace: $NAMESPACE"

if helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
    echo "♻️  Upgrading existing release..."
    helm upgrade $RELEASE_NAME helm/blog-app -n $NAMESPACE
else
    echo "🆕 Installing new release..."
    helm install $RELEASE_NAME helm/blog-app -n $NAMESPACE --create-namespace
fi

# Wait for deployment
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=blog-app -n $NAMESPACE --timeout=180s

# Display deployment status
echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Release Status:"
helm status $RELEASE_NAME -n $NAMESPACE
echo ""
echo "🌐 Services:"
kubectl get services -n $NAMESPACE
echo ""
echo "💡 To access the application:"
echo "   Run: kubectl port-forward service/frontend 3000:80 -n $NAMESPACE"
echo "   Then open: http://localhost:3000"
echo ""
echo "📋 Useful commands:"
echo "   helm list -n $NAMESPACE"
echo "   kubectl get pods -n $NAMESPACE"
echo "   helm uninstall $RELEASE_NAME -n $NAMESPACE"
