@echo off
echo 🎮 Trivia Game Load Test Runner
echo ===============================

REM Check if Dart is installed
dart --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Dart is not installed. Please install Dart first.
    pause
    exit /b 1
)

REM Check if dependencies are installed
if not exist "pubspec.lock" (
    echo 📦 Installing dependencies...
    dart pub get
)

REM Check if the load test file exists
if not exist "test_trivia_load_test.dart" (
    echo ❌ test_trivia_load_test.dart not found!
    pause
    exit /b 1
)

REM Update server URL if provided
if not "%1"=="" (
    echo 🔧 Updating server URL to: %1
    powershell -Command "(Get-Content test_trivia_load_test.dart) -replace 'ws://localhost:3000', '%1' | Set-Content test_trivia_load_test.dart"
    powershell -Command "(Get-Content test_trivia_load_test.dart) -replace 'http://localhost:3000', '%1' | Set-Content test_trivia_load_test.dart"
)

echo 🚀 Starting load test...
echo.

REM Run the load test
dart test_trivia_load_test.dart

echo.
echo ✅ Load test completed!
pause 