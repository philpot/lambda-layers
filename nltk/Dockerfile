# Use Amazon Linux 2023 base image to match Lambda runtime
FROM amazonlinux:2023

# Install Python 3.11 and development tools
RUN yum update -y && \
    yum install -y python3.11 python3.11-pip python3.11-devel gcc make && \
    yum clean all

# Create the layer directory structure
RUN mkdir -p /opt/python /opt/python/nltk_data

# Set working directory
WORKDIR /app

# Copy requirements and download script
COPY requirements.txt download_data.py ./

# Install Python packages to the layer directory
# Force compilation from source to ensure Amazon Linux compatibility
RUN python3.11 -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    python3.11 -m pip install --no-cache-dir --no-binary=regex --force-reinstall --no-deps regex==2023.12.25 -t /opt/python/ && \
    python3.11 -m pip install --no-cache-dir nltk==3.8.1 joblib==1.3.2 -t /opt/python/

# Download NLTK data (after installing NLTK)
ENV NLTK_DATA=/opt/python/nltk_data
ENV PYTHONPATH=/opt/python
RUN python3.11 download_data.py

# Clean up unnecessary files to reduce size
RUN find /opt/python -name "*.pyc" -delete && \
    find /opt/python -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find /opt/python -name "*.dist-info" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find /opt/python -name "tests" -type d -exec rm -rf {} + 2>/dev/null || true

# Create the final layer zip
WORKDIR /opt
RUN zip -r9 /layer.zip . -x "*.pyc" "*/__pycache__/*"

# Copy test script for validation
COPY test_layer.py /app/
WORKDIR /app

# Default command runs tests
CMD ["python3.11", "test_layer.py"]
