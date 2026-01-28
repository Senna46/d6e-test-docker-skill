#!/bin/bash
# Local test script for d6e-test-docker-skill
set -e

IMAGE_NAME="d6e-test-skill:latest"

echo "🏗️  Building Docker image..."
docker build -t $IMAGE_NAME .

echo ""
echo "🧪 Test 1: Basic test"
echo '{"workspace_id":"01234567-89ab-cdef-0123-456789abcdef","stf_id":"01234567-89ab-cdef-0123-456789abcdef","input":{"operation":"test"},"sources":{"config":{"key":"value"}},"caller":"01234567-89ab-cdef-0123-456789abcdef","api_url":"http://host.docker.internal:8080","api_token":"d6e-internal-stf-execution"}' | \
  docker run --rm -i $IMAGE_NAME

echo ""
echo "🧪 Test 2: Unknown operation"
echo '{"workspace_id":"01234567-89ab-cdef-0123-456789abcdef","stf_id":"01234567-89ab-cdef-0123-456789abcdef","input":{"operation":"unknown"},"sources":{},"caller":null,"api_url":"http://host.docker.internal:8080","api_token":"d6e-internal-stf-execution"}' | \
  docker run --rm -i $IMAGE_NAME

echo ""
echo "🧪 Test 3: Error handling"
echo '{"workspace_id":"01234567-89ab-cdef-0123-456789abcdef","stf_id":"01234567-89ab-cdef-0123-456789abcdef","input":{"operation":"error"},"sources":{},"caller":null,"api_url":"http://host.docker.internal:8080","api_token":"d6e-internal-stf-execution"}' | \
  docker run --rm -i $IMAGE_NAME || echo "Expected error occurred"

echo ""
echo "✅ Local tests completed!"
echo ""
echo "Next steps:"
echo "1. Start D6E server: cd /home/user/github.com/KimuraYu45z/d6e && docker compose -f compose.withdb.yml up"
echo "2. Follow the test guide: /home/user/github.com/KimuraYu45z/d6e/docs/09-testing-docker-runtime.md"
