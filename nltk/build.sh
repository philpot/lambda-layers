#!/bin/bash
set -e

# NLTK Lambda Layer Build Script
# Builds a Lambda layer containing NLTK with pre-downloaded data

LAYER_NAME="nltk-python311"
BUILD_DIR="build"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Building NLTK Lambda Layer"
echo "================================"

# Clean up previous builds
if [ -d "$BUILD_DIR" ]; then
    echo "🧹 Cleaning previous build..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"

# Build the Docker image
echo "🐳 Building Docker image for x86_64 platform..."
docker build --platform linux/amd64 -t "$LAYER_NAME-builder" "$SCRIPT_DIR"

# Extract the layer zip from the container
echo "📦 Extracting layer package..."
CONTAINER_ID=$(docker create "$LAYER_NAME-builder")
docker cp "$CONTAINER_ID:/layer.zip" "$BUILD_DIR/"
docker rm "$CONTAINER_ID" > /dev/null

# Verify the build
echo "🔍 Verifying layer contents..."
cd "$BUILD_DIR"
unzip -l layer.zip | head -20

# Check layer size
LAYER_SIZE=$(du -h layer.zip | cut -f1)
echo "📏 Layer size: $LAYER_SIZE"

# Size warning
LAYER_SIZE_BYTES=$(stat -f%z layer.zip 2>/dev/null || stat -c%s layer.zip 2>/dev/null)
MAX_SIZE_BYTES=$((50 * 1024 * 1024))  # 50MB limit

if [ "$LAYER_SIZE_BYTES" -gt "$MAX_SIZE_BYTES" ]; then
    echo "⚠️  WARNING: Layer size ($LAYER_SIZE) exceeds AWS limit (50MB)"
    echo "   Consider removing unnecessary packages or data"
else
    echo "✅ Layer size is within AWS limits"
fi

echo ""
echo "🎉 Build complete!"
echo "   Layer package: $BUILD_DIR/layer.zip"
echo ""
echo "Next steps:"
echo "1. Test the layer:"
echo "   docker run --rm -v \$(pwd)/$BUILD_DIR:/mnt $LAYER_NAME-builder python3.11 -c \"import sys; sys.path.insert(0, '/opt/python'); import nltk; print('✓ NLTK import successful')\""
echo ""
echo "2. Deploy to AWS:"
echo "   aws lambda publish-layer-version \\"
echo "     --layer-name $LAYER_NAME \\"
echo "     --zip-file fileb://$BUILD_DIR/layer.zip \\"
echo "     --compatible-runtimes python3.11 \\"
echo "     --compatible-architectures x86_64 \\"
echo "     --description \"NLTK library with vader_lexicon and punkt data\" \\"
echo "     --region us-east-2"
