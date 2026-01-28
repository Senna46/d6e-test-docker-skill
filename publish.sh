#!/bin/bash
# Publish Docker image to GitHub Container Registry
set -e

IMAGE_NAME="d6e-test-skill"
REGISTRY="ghcr.io/senna46/d6e-test-docker-skill"
VERSION="1.0.0"

echo "🏗️  Building Docker image..."
docker build -t $IMAGE_NAME:latest .

echo ""
echo "🏷️  Tagging image..."
docker tag $IMAGE_NAME:latest $REGISTRY:latest
docker tag $IMAGE_NAME:latest $REGISTRY:$VERSION

echo ""
echo "📤 Pushing to GitHub Container Registry..."
echo "   Make sure you're logged in: docker login ghcr.io -u Senna46"
echo ""

# Check if logged in
if docker push $REGISTRY:latest 2>&1 | grep -q "unauthorized"; then
    echo "❌ Not authenticated. Please run:"
    echo "   docker login ghcr.io -u Senna46"
    exit 1
fi

docker push $REGISTRY:$VERSION

echo ""
echo "✅ Successfully published!"
echo ""
echo "📦 Image URLs:"
echo "   - $REGISTRY:latest"
echo "   - $REGISTRY:$VERSION"
echo ""
echo "🧪 Test with:"
echo "   docker pull $REGISTRY:latest"
echo "   echo '{...}' | docker run --rm -i $REGISTRY:latest"
echo ""
echo "💡 To make the image public:"
echo "   1. Visit https://github.com/users/Senna46/packages"
echo "   2. Click on 'd6e-test-docker-skill'"
echo "   3. Package settings → Change visibility → Public"
