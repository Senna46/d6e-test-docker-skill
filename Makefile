.PHONY: build test-local clean

# Docker image name
IMAGE_NAME := d6e-test-skill
IMAGE_TAG := latest

# Build Docker image
build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "✅ Image built: $(IMAGE_NAME):$(IMAGE_TAG)"
	@docker images | grep $(IMAGE_NAME)

# Test locally with sample input
test-local: build
	@echo "🧪 Testing with sample input..."
	@echo '{"workspace_id":"01234567-89ab-cdef-0123-456789abcdef","stf_id":"01234567-89ab-cdef-0123-456789abcdef","input":{"operation":"test"},"sources":{},"caller":null,"api_url":"http://host.docker.internal:8080","api_token":"d6e-internal-stf-execution"}' | \
		docker run --rm -i $(IMAGE_NAME):$(IMAGE_TAG)

# Clean up
clean:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true

# Show help
help:
	@echo "Available targets:"
	@echo "  make build       - Build Docker image"
	@echo "  make test-local  - Test image locally with sample input"
	@echo "  make clean       - Remove Docker image"
	@echo "  make help        - Show this help"
