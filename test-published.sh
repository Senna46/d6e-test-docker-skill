#!/bin/bash
# Test published Docker image from GitHub Container Registry
set -e

REGISTRY="ghcr.io/senna46/d6e-test-docker-skill"
VERSION="${1:-latest}"

echo "🧹 Cleaning up local images..."
docker rmi d6e-test-skill:latest 2>/dev/null || true
docker rmi $REGISTRY:latest 2>/dev/null || true
docker rmi $REGISTRY:$VERSION 2>/dev/null || true

echo ""
echo "📥 Pulling image from GitHub Container Registry..."
docker pull $REGISTRY:$VERSION

echo ""
echo "🧪 Test 1: Basic test"
echo '{"workspace_id":"01234567-89ab-cdef-0123-456789abcdef","stf_id":"01234567-89ab-cdef-0123-456789abcdef","input":{"operation":"test"},"sources":{"config":{"key":"value"}},"caller":"01234567-89ab-cdef-0123-456789abcdef","api_url":"http://host.docker.internal:8080","api_token":"d6e-internal-stf-execution"}' | \
  docker run --rm -i $REGISTRY:$VERSION

echo ""
echo "🧪 Test 2: Unknown operation"
echo '{"workspace_id":"01234567-89ab-cdef-0123-456789abcdef","stf_id":"01234567-89ab-cdef-0123-456789abcdef","input":{"operation":"unknown"},"sources":{},"caller":null,"api_url":"http://host.docker.internal:8080","api_token":"d6e-internal-stf-execution"}' | \
  docker run --rm -i $REGISTRY:$VERSION

echo ""
echo "🧪 Test 3: Error handling"
echo '{"workspace_id":"01234567-89ab-cdef-0123-456789abcdef","stf_id":"01234567-89ab-cdef-0123-456789abcdef","input":{"operation":"error"},"sources":{},"caller":null,"api_url":"http://host.docker.internal:8080","api_token":"d6e-internal-stf-execution"}' | \
  docker run --rm -i $REGISTRY:$VERSION || echo "✅ Expected error occurred"

echo ""
echo "✅ All tests passed!"
echo ""
echo "📦 Image: $REGISTRY:$VERSION"
echo "🔍 Image size:"
docker images $REGISTRY:$VERSION

echo ""
echo "🚀 Ready to use in D6E!"
echo "   Use this in STF code field:"
echo "   {\"image\":\"$REGISTRY:$VERSION\"}"
