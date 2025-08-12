#!/usr/bin/env python3.11
"""
Download essential NLTK data packages for the Lambda layer.
"""

import nltk
import os
import sys

def main():
    # Set the download directory to the layer's nltk_data path
    nltk_data_dir = os.environ.get('NLTK_DATA', '/opt/python/nltk_data')

    print(f"Downloading NLTK data to: {nltk_data_dir}")

    # Data packages to download
    packages = [
        'vader_lexicon',  # For sentiment analysis
        'punkt',          # For sentence tokenization
    ]

    success_count = 0
    for package in packages:
        try:
            print(f"Downloading {package}...")
            nltk.download(package, download_dir=nltk_data_dir, quiet=False)
            success_count += 1
            print(f"✓ {package} downloaded successfully")
        except Exception as e:
            print(f"✗ Failed to download {package}: {e}")
            # Don't exit on individual failures, continue with others

    print(f"\nDownload complete: {success_count}/{len(packages)} packages successful")

    # Verify the downloads
    print("\nVerifying downloads...")
    nltk.data.path.insert(0, nltk_data_dir)

    verification_tests = [
        ('vader_lexicon', lambda: nltk.data.find('vader_lexicon')),
        ('punkt', lambda: nltk.data.find('tokenizers/punkt')),
    ]

    verified_count = 0
    for name, test_func in verification_tests:
        try:
            test_func()
            print(f"✓ {name} verified")
            verified_count += 1
        except Exception as e:
            print(f"✗ {name} verification failed: {e}")

    print(f"\nVerification complete: {verified_count}/{len(verification_tests)} packages verified")

    if verified_count != len(verification_tests):
        print("Some packages failed verification!")
        sys.exit(1)

    print("All NLTK data successfully downloaded and verified!")

if __name__ == "__main__":
    main()
