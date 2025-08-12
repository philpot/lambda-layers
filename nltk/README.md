# NLTK Lambda Layer

AWS Lambda layer containing the complete NLTK library with pre-downloaded essential data packages.

## What's Included

### Python Packages
- `nltk` (latest stable)
- `regex` (NLTK dependency)
- `joblib` (NLTK dependency)

### Pre-downloaded NLTK Data
- `vader_lexicon` - For sentiment analysis
- `punkt` - For sentence tokenization

## Layer ARNs

### us-east-2 (Ohio)
```
arn:aws:lambda:us-east-2:YOUR_ACCOUNT:layer:nltk-python311:1
```

## Usage

### Basic Sentiment Analysis
```python
import json
from nltk.sentiment import SentimentIntensityAnalyzer

def lambda_handler(event, context):
    # Initialize sentiment analyzer (data is pre-loaded)
    sia = SentimentIntensityAnalyzer()

    text = event.get('text', '')
    sentiment = sia.polarity_scores(text)

    return {
        'statusCode': 200,
        'body': json.dumps({
            'text': text,
            'sentiment': sentiment
        })
    }
```

### Sentence Tokenization
```python
import nltk

def lambda_handler(event, context):
    text = event.get('text', '')

    # Punkt data is pre-loaded
    sentences = nltk.sent_tokenize(text)

    return {
        'statusCode': 200,
        'body': json.dumps({
            'sentences': sentences,
            'count': len(sentences)
        })
    }
```

### Adding More NLTK Data

If you need additional NLTK data not included in this layer, download it in your Lambda function:

```python
import nltk
import os

def lambda_handler(event, context):
    # Download to Lambda's writable /tmp directory
    nltk.data.path.append('/tmp')

    try:
        # Try to use existing data first
        nltk.data.find('tokenizers/punkt')
    except LookupError:
        # Download if not found
        nltk.download('punkt', download_dir='/tmp')

    # Your code here
```

## Configuration

### SAM Template
```yaml
Resources:
  MyFunction:
    Type: AWS::Serverless::Function
    Properties:
      Runtime: python3.11
      Layers:
        - arn:aws:lambda:us-east-2:YOUR_ACCOUNT:layer:nltk-python311:1
```

### Serverless Framework
```yaml
functions:
  sentiment:
    handler: handler.sentiment_analysis
    runtime: python3.11
    layers:
      - arn:aws:lambda:us-east-2:YOUR_ACCOUNT:layer:nltk-python311:1
```

### Terraform
```hcl
resource "aws_lambda_function" "sentiment" {
  function_name = "sentiment-analysis"
  runtime       = "python3.11"

  layers = [
    "arn:aws:lambda:us-east-2:YOUR_ACCOUNT:layer:nltk-python311:1"
  ]
}
```

## Layer Details

- **Runtime**: Python 3.11
- **Architecture**: x86_64
- **Approximate Size**: 45MB (zipped)
- **Data Location**: `/opt/python/nltk_data/`
- **Package Location**: `/opt/python/`

## Troubleshooting

### Import Errors
Ensure your Lambda function runtime is Python 3.11. Other Python versions are not supported.

### Missing Data
The layer includes vader_lexicon and punkt data. For other datasets, download them to `/tmp` as shown above.

### Memory Issues
NLTK can be memory-intensive. Consider increasing your Lambda function's memory allocation (512MB+ recommended).

## Building This Layer

To build this layer yourself:

```bash
# Clone the repository
git clone https://github.com/philpot/lambda-layers.git
cd lambda-layers/nltk

# Build the layer
./build.sh

# Test the layer
python test_layer.py
```

## Changelog

### Version 1 (Initial Release)
- Complete NLTK package
- Pre-loaded vader_lexicon for sentiment analysis
- Pre-loaded punkt for tokenization
- Python 3.11 support
- Built for Amazon Linux 2023
