import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool _loading = true;
  bool _apiSuccess = false;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardHistory();
  }

  Future<void> _fetchLeaderboardHistory() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.fetchLeaderboardHistory();
    setState(() {
      _loading = false;
      _apiSuccess = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = context.watch<AuthService>();
    final leaderboardHistory = authService.leaderboardHistory;
    final historyList =
        leaderboardHistory != null && leaderboardHistory['history'] is List
            ? leaderboardHistory['history'] as List
            : [];
    final showApiData = _apiSuccess && historyList.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1615), // Darker teal-black at top
              Color(0xFF0A0E0D), // Dark background in middle
              Color(0xFF0E1211), // Slightly lighter at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : showApiData
                  ? _buildHistoryListView(historyList)
                  : _buildNoHistoryView(),
        ),
      ),
    );
  }

  Widget _buildHistoryListView(List historyList) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: historyList.length,
      itemBuilder: (context, index) {
        final item = historyList[index] as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF94C1BA).withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Competition ID
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF94C1BA).withOpacity(0.2),
                          border: Border.all(
                            color: const Color(0xFF94C1BA),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${item['competition_id'] ?? ''}',
                            style: const TextStyle(
                              color: Color(0xFF94C1BA),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Nickname
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nickname'] ?? 'Player',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rank: ${item['rank'] ?? 'N/A'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Score
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Score: ${item['score'] ?? 'N/A'}',
                            style: const TextStyle(
                              color: Color(0xFF94C1BA),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoHistoryView() {
    return Center(
      child: Text(
        'No history found.',
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildDummyHistoryView(List<Map<String, dynamic>> historyItems) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final item = historyItems[index];
        final bool isUser = item['isUser'] as bool;
        final bool hasHighlight = isUser;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: hasHighlight
                      ? Border.all(
                          color: const Color(0xFF94C1BA).withOpacity(0.5),
                          width: 1)
                      : Border.all(
                          color: Colors.white.withOpacity(0.1), width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00B894),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00B894).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/images/avatar.png',
                            errorBuilder: (context, error, stackTrace) {
                              return CircleAvatar(
                                backgroundColor:
                                    const Color(0xFF00B894).withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xFF00B894),
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Name and phone
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: TextStyle(
                                    color: isUser
                                        ? const Color(0xFF94C1BA)
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (item['lastName'] != '')
                                  Text(
                                    ' ${item['lastName']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['phone'] as String,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Position and date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['position'] as String,
                            style: TextStyle(
                              color:
                                  _getPositionColor(item['position'] as String),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (item['date'] != '')
                            Text(
                              item['date'] as String,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          if (item['badge'] != '')
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF94C1BA).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      const Color(0xFF94C1BA).withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.military_tech,
                                    color: Color(0xFF94C1BA),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['badge'] as String,
                                    style: const TextStyle(
                                      color: Color(0xFF94C1BA),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getPositionColor(String position) {
    if (position == 'Top 1') {
      return const Color(0xFF94C1BA); // Primary teal color
    } else if (position == 'Top 2' || position == 'Top 3') {
      return const Color(0xFF94C1BA); // Primary teal color
    } else {
      return const Color(0xFF94C1BA); // Primary teal color for all positions
    }
  }
}
