# 🎮 Trivia Game Load Test Tool

A comprehensive load testing tool for your trivia game that simulates 100 real-time users playing simultaneously.

## 📋 Features

- **100 Concurrent Users**: Simulates 100 users connecting and playing simultaneously
- **Realistic Behavior**: Users have different answering patterns (random, strategic, etc.)
- **Gradual Ramp-up**: Users connect gradually over 30 seconds to avoid overwhelming the server
- **Real-time Monitoring**: Live status updates every 10 seconds
- **Detailed Reporting**: Comprehensive test results with user statistics
- **Performance Metrics**: Response times, accuracy rates, and connection statistics
- **JSON Export**: Detailed results saved to timestamped JSON files

## 🚀 Quick Start

### Prerequisites

1. **Dart SDK**: Make sure you have Dart installed
2. **Trivia Server**: Your trivia game server should be running
3. **Dependencies**: The tool uses `socket_io_client` and `http` packages

### Running the Test

#### Option 1: Using the Script (Recommended)

**Linux/Mac:**
```bash
chmod +x run_load_test.sh
./run_load_test.sh
```

**Windows:**
```cmd
run_load_test.bat
```

#### Option 2: Manual Execution

```bash
dart test_trivia_load_test.dart
```

### Custom Server URL

If your server is not running on `localhost:3000`, you can specify a custom URL:

**Linux/Mac:**
```bash
./run_load_test.sh ws://your-server.com:3000
```

**Windows:**
```cmd
run_load_test.bat ws://your-server.com:3000
```

## ⚙️ Configuration

Edit `test_trivia_load_test.dart` to modify test parameters:

```dart
class LoadTestConfig {
  static const int totalUsers = 100;           // Number of users to simulate
  static const int rampUpTimeSeconds = 30;     // Time to start all users
  static const int testDurationSeconds = 300;  // Test duration (5 minutes)
  static const String serverUrl = 'ws://localhost:3000';
  static const String apiBaseUrl = 'http://localhost:3000';
}
```

## 📊 Test Behavior

### User Simulation

Each test user:
1. **Connects** to the socket server
2. **Joins** a competition (`test_competition_1`)
3. **Listens** for questions
4. **Answers** questions with realistic delays (1-3 seconds)
5. **Tracks** performance metrics

### Answering Patterns

Users simulate different behaviors:
- **70%**: Random answers
- **15%**: Always choose first option
- **10%**: Always choose last option  
- **5%**: "Intelligent" answers (simulating correct responses)

### Timing

- **Ramp-up**: 30 seconds to start all 100 users
- **Test Duration**: 5 minutes of active gameplay
- **Answer Delays**: 1-3 seconds per question
- **Status Updates**: Every 10 seconds

## 📈 Understanding Results

### Real-time Status

During the test, you'll see updates like:
```
⏱️  Test Status (45s elapsed):
   - Connected Users: 98/100
   - Joined Competition: 95
   - Questions Received: 285
   - Answers Submitted: 267
```

### Final Report

The test generates a comprehensive report:
```
📊 LOAD TEST REPORT
==================
Test Duration: 300s
Total Users: 100
Connected Users: 98
Joined Competition: 95
Questions Received: 285
Answers Submitted: 267

📈 Averages:
   - Questions per User: 3.00
   - Answers per User: 2.81

👥 User Statistics:
Top 10 Users by Accuracy:
   1. TestUser_045: 75.00% (3/4)
   2. TestUser_023: 66.67% (2/3)
   ...
```

### JSON Results File

Detailed results are saved to `trivia_load_test_results_YYYY-MM-DDTHH-MM-SS.json` containing:
- Test configuration
- Overall statistics
- Individual user performance
- Timing data
- Connection status

## 🔍 Performance Indicators

### Good Performance
- **Connection Rate**: >95% of users connect successfully
- **Response Time**: <2 seconds for first answer
- **Question Delivery**: All users receive questions
- **Answer Submission**: >90% of questions get answered

### Warning Signs
- **Low Connection Rate**: <80% users connect
- **High Response Times**: >5 seconds for answers
- **Missing Questions**: Users not receiving questions
- **Socket Errors**: Connection failures or timeouts

## 🛠️ Troubleshooting

### Common Issues

1. **"Cannot reach server"**
   - Ensure your trivia server is running
   - Check the server URL in configuration
   - Verify firewall settings

2. **"Socket connection error"**
   - Check if WebSocket is enabled on your server
   - Verify CORS settings
   - Check server logs for errors

3. **"Low connection rate"**
   - Server may be overloaded
   - Check server resources (CPU, memory)
   - Consider reducing `totalUsers` for testing

### Server Requirements

For 100 concurrent users, your server should have:
- **CPU**: 2+ cores recommended
- **Memory**: 2GB+ RAM
- **Network**: Stable internet connection
- **WebSocket Support**: Properly configured

## 📝 Customization

### Adding New Metrics

To track additional metrics, modify the `TestUser.getStats()` method:

```dart
Map<String, dynamic> getStats() {
  return {
    // ... existing stats
    'customMetric': yourCustomValue,
  };
}
```

### Changing User Behavior

Modify the `simulateAnswer()` method to change how users answer:

```dart
void simulateAnswer(String questionId, List<String> options) {
  // Your custom logic here
}
```

### Extending Test Duration

Change `testDurationSeconds` in `LoadTestConfig` for longer tests.

## 🎯 Use Cases

1. **Performance Testing**: Verify server handles 100+ concurrent users
2. **Load Testing**: Test server limits and breaking points
3. **Regression Testing**: Ensure updates don't break performance
4. **Capacity Planning**: Determine server requirements for production
5. **Bug Hunting**: Find race conditions and timing issues

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review server logs for errors
3. Verify all dependencies are installed
4. Test with fewer users first (modify `totalUsers`)

---

**Happy Testing! 🎮** 