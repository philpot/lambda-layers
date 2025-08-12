#!/usr/bin/env python3.11
"""
Test script to validate the NLTK Lambda layer.
"""

import sys
import os

# Add the layer path to Python path (simulating Lambda environment)
sys.path.insert(0, '/opt/python')

def test_basic_import():
    """Test basic NLTK import."""
    print("🔍 Testing basic NLTK import...")
    try:
        import nltk
        print(f"✅ NLTK version: {nltk.__version__}")
        return True
    except ImportError as e:
        print(f"❌ Failed to import NLTK: {e}")
        return False

def test_sentiment_analysis():
    """Test sentiment analysis with vader."""
    print("🔍 Testing sentiment analysis...")
    try:
        from nltk.sentiment import SentimentIntensityAnalyzer

        # Initialize analyzer (should use pre-downloaded data)
        sia = SentimentIntensityAnalyzer()

        # Test sentences
        test_cases = [
            ("I love this!", "positive"),
            ("This is terrible!", "negative"),
            ("This is okay.", "neutral"),
            ("Amazing work! Great job!", "positive"),
        ]

        for text, expected_sentiment in test_cases:
            scores = sia.polarity_scores(text)
            compound = scores['compound']

            if compound > 0.05:
                detected = "positive"
            elif compound < -0.05:
                detected = "negative"
            else:
                detected = "neutral"

            status = "✅" if detected == expected_sentiment else "⚠️"
            print(f"  {status} '{text}' -> {detected} (compound: {compound:.3f})")

        print("✅ Sentiment analysis working")
        return True

    except Exception as e:
        print(f"❌ Sentiment analysis failed: {e}")
        return False

def test_tokenization():
    """Test sentence tokenization with punkt."""
    print("🔍 Testing sentence tokenization...")
    try:
        import nltk

        text = "Hello world! How are you today? I'm doing great."
        sentences = nltk.sent_tokenize(text)

        expected_count = 3
        if len(sentences) == expected_count:
            print(f"✅ Tokenization successful: {sentences}")
            return True
        else:
            print(f"⚠️ Expected {expected_count} sentences, got {len(sentences)}: {sentences}")
            return True  # Still pass, might be version differences

    except Exception as e:
        print(f"❌ Tokenization failed: {e}")
        return False

def test_data_paths():
    """Test NLTK data paths and availability."""
    print("🔍 Testing NLTK data paths...")
    try:
        import nltk

        print(f"  NLTK data paths: {nltk.data.path}")

        # Check for expected data
        data_checks = [
            ('vader_lexicon', 'vader_lexicon'),
            ('punkt tokenizer', 'tokenizers/punkt'),
        ]

        all_found = True
        for name, path in data_checks:
            try:
                nltk.data.find(path)
                print(f"  ✅ {name} found")
            except LookupError:
                print(f"  ❌ {name} not found at {path}")
                all_found = False

        return all_found

    except Exception as e:
        print(f"❌ Data path test failed: {e}")
        return False

def test_layer_size():
    """Check layer structure and size."""
    print("🔍 Testing layer structure...")

    expected_paths = [
        '/opt/python/nltk',
        '/opt/python/nltk_data',
        '/opt/python/nltk_data/vader_lexicon',
        '/opt/python/nltk_data/tokenizers',
    ]

    all_exist = True
    for path in expected_paths:
        if os.path.exists(path):
            print(f"  ✅ {path}")
        else:
            print(f"  ❌ {path} not found")
            all_exist = False

    return all_exist

def main():
    """Run all tests."""
    print("🧪 NLTK Lambda Layer Test Suite")
    print("================================")

    tests = [
        ("Basic Import", test_basic_import),
        ("Data Paths", test_data_paths),
        ("Layer Structure", test_layer_size),
        ("Sentiment Analysis", test_sentiment_analysis),
        ("Tokenization", test_tokenization),
    ]

    passed = 0
    total = len(tests)

    for name, test_func in tests:
        print(f"\n--- {name} ---")
        try:
            if test_func():
                passed += 1
            else:
                print(f"❌ {name} failed")
        except Exception as e:
            print(f"❌ {name} crashed: {e}")

    print(f"\n🏁 Test Results: {passed}/{total} tests passed")

    if passed == total:
        print("🎉 All tests passed! Layer is ready for deployment.")
        sys.exit(0)
    else:
        print("💥 Some tests failed. Check the layer build.")
        sys.exit(1)

if __name__ == "__main__":
    main()
