#!/bin/bash
# Common utilities for Lambda layer building

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if required tools are installed
check_requirements() {
    local missing=0

    if ! command -v docker &> /dev/null; then
        log_error "Docker is required but not installed"
        missing=1
    fi

    if ! command -v aws &> /dev/null; then
        log_warning "AWS CLI not found - deployment features will be unavailable"
    fi

    if [ $missing -eq 1 ]; then
        exit 1
    fi
}

# Validate AWS configuration
check_aws_config() {
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured or invalid"
        log_info "Run: aws configure"
        return 1
    fi

    local account_id=$(aws sts get-caller-identity --query Account --output text)
    log_info "AWS Account: $account_id"
    return 0
}

# Clean up Docker resources
cleanup_docker() {
    local image_name="$1"

    if [ -n "$image_name" ]; then
        log_info "Cleaning up Docker resources..."

        # Remove stopped containers
        docker container prune -f &> /dev/null || true

        # Remove the builder image if it exists
        if docker images "$image_name" -q | grep -q .; then
            docker rmi "$image_name" &> /dev/null || true
        fi
    fi
}

# Deploy layer to AWS
deploy_layer() {
    local layer_name="$1"
    local zip_file="$2"
    local description="$3"
    local runtime="${4:-python3.11}"
    local region="${5:-us-east-2}"

    if [ ! -f "$zip_file" ]; then
        log_error "Layer zip file not found: $zip_file"
        return 1
    fi

    if ! check_aws_config; then
        return 1
    fi

    log_info "Deploying layer '$layer_name' to region '$region'..."
    log_info "Zip file: $zip_file ($(du -h "$zip_file" | cut -f1))"

    # Deploy the layer
    local layer_arn
    layer_arn=$(aws lambda publish-layer-version \
        --layer-name "$layer_name" \
        --zip-file "fileb://$zip_file" \
        --compatible-runtimes "$runtime" \
        --compatible-architectures x86_64 \
        --description "$description" \
        --region "$region" \
        --query 'LayerVersionArn' \
        --output text 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$layer_arn" ]; then
        log_success "Layer deployed successfully!"
        log_info "Layer ARN: $layer_arn"
        return 0
    else
        log_error "Failed to deploy layer"
        return 1
    fi
}

# Get the size of a file in MB
get_file_size_mb() {
    local file="$1"
    if [ -f "$file" ]; then
        local size_bytes
        size_bytes=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        echo $((size_bytes / 1024 / 1024))
    else
        echo "0"
    fi
}

# Validate layer size against AWS limits
validate_layer_size() {
    local zip_file="$1"
    local max_size_mb="${2:-50}"

    if [ ! -f "$zip_file" ]; then
        log_error "Zip file not found: $zip_file"
        return 1
    fi

    local size_mb
    size_mb=$(get_file_size_mb "$zip_file")

    log_info "Layer size: ${size_mb}MB"

    if [ "$size_mb" -gt "$max_size_mb" ]; then
        log_error "Layer size (${size_mb}MB) exceeds AWS limit (${max_size_mb}MB)"
        return 1
    else
        log_success "Layer size within limits"
        return 0
    fi
}

# Extract and show layer contents
inspect_layer() {
    local zip_file="$1"
    local max_lines="${2:-20}"

    if [ ! -f "$zip_file" ]; then
        log_error "Zip file not found: $zip_file"
        return 1
    fi

    log_info "Layer contents (first $max_lines items):"
    unzip -l "$zip_file" | head -n $((max_lines + 3))

    local total_files
    total_files=$(unzip -l "$zip_file" | tail -1 | awk '{print $2}')
    log_info "Total files in layer: $total_files"
}
