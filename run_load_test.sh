#!/bin/bash

echo "🎮 Trivia Game Load Test Runner"
echo "==============================="

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "❌ Dart is not installed. Please install Dart first."
    exit 1
fi

# Check if dependencies are installed
if [ ! -f "pubspec.lock" ]; then
    echo "📦 Installing dependencies..."
    dart pub get
fi

# Check if the load test file exists
if [ ! -f "test_trivia_load_test.dart" ]; then
    echo "❌ test_trivia_load_test.dart not found!"
    exit 1
fi

# Update server URL if provided
if [ ! -z "$1" ]; then
    echo "🔧 Updating server URL to: $1"
    sed -i "s|ws://localhost:3000|$1|g" test_trivia_load_test.dart
    sed -i "s|http://localhost:3000|${1/ws:/http:}|g" test_trivia_load_test.dart
fi

echo "🚀 Starting load test..."
echo ""

# Run the load test
dart test_trivia_load_test.dart

echo ""
echo "✅ Load test completed!" 