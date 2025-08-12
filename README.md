# Lambda Layers

A collection of AWS Lambda layers for Python, built for Amazon Linux 2023 and optimized for production use.

## Available Layers

### NLTK Layer
- **Runtime**: Python 3.11
- **Includes**: Complete NLTK package with pre-downloaded vader_lexicon and punkt data
- **Size**: ~45MB zipped
- **ARN**: `arn:aws:lambda:us-east-2:YOUR_ACCOUNT:layer:nltk-python311:1`

[→ View NLTK Layer Documentation](./nltk/README.md)

## Quick Start

Add the layer to your Lambda function:

```python
import nltk
from nltk.sentiment import SentimentIntensityAnalyzer

# Data is pre-loaded, no download needed
sia = SentimentIntensityAnalyzer()
score = sia.polarity_scores("This is a great day!")
print(score)  # {'neg': 0.0, 'neu': 0.294, 'pos': 0.706, 'compound': 0.6249}
```

## Building Layers

All layers are built using Docker to ensure Amazon Linux compatibility:

```bash
cd nltk/
./build.sh
```

## Available Regions

Currently available in:
- `us-east-2` (Ohio)

Need other regions? [Open an issue](https://github.com/philpot/lambda-layers/issues) or submit a PR to add them.

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

See individual layer directories for specific contribution guidelines.

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.

## Support

This is a community project. While we'll do our best to help:

- Use GitHub Issues for bugs and feature requests
- Check existing issues before creating new ones
- PRs are preferred over feature requests

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.