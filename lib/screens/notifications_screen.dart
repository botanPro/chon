import 'package:flutter/material.dart';
import 'dart:ui';

/// A model class representing a notification in the app
class AppNotification {
  /// The type of notification (e.g., 'game', 'announcement', 'warning')
  final String type;

  /// The title of the notification
  final String title;

  /// The main message content
  final String message;

  /// When the notification was received
  final String time;

  /// The icon type to display ('chon', 'gamepad', 'warning')
  final String icon;

  /// Whether this notification should be visually highlighted
  final bool isHighlighted;

  /// Creates a new notification instance
  const AppNotification({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.isHighlighted = false,
  });

  /// Creates a notification from a map
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      type: map['type'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      time: map['time'] as String,
      icon: map['icon'] as String,
      isHighlighted: map['isHighlighted'] as bool? ?? false,
    );
  }
}

/// Screen that displays a list of notifications to the user.
///
/// Features a glassmorphic UI with special highlighting for important notifications.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample notification data - would be replaced with API data in production
    final List<AppNotification> notifications = _getSampleNotifications();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
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
          child: _buildNotificationsList(notifications),
        ),
      ),
    );
  }

  /// Builds the app bar with title only
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Builds the scrollable list of notifications
  Widget _buildNotificationsList(List<AppNotification> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  /// Builds a single notification card with glassmorphic effect
  Widget _buildNotificationCard(AppNotification notification) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              // Yellow background for highlighted notifications, otherwise transparent black
              color: notification.isHighlighted
                  ? const Color(0xFFFFD700).withOpacity(0.2)
                  : Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: notification.isHighlighted
                    ? const Color(0xFFFFD700).withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification icon
                  _buildNotificationIcon(notification.icon),
                  const SizedBox(width: 12),
                  // Notification content
                  Expanded(
                    child: _buildNotificationContent(notification),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the content section of the notification card
  Widget _buildNotificationContent(AppNotification notification) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              notification.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              notification.time,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          notification.message,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Builds the appropriate icon based on the notification type
  Widget _buildNotificationIcon(String iconType) {
    switch (iconType) {
      case 'chon':
        return _buildChonLogo();
      case 'gamepad':
        return _buildIconContainer(
          icon: Icons.sports_esports,
          borderColor: Colors.white.withOpacity(0.2),
        );
      case 'warning':
        return _buildIconContainer(
          icon: Icons.warning_rounded,
          borderColor: Colors.white.withOpacity(0.2),
        );
      default:
        return _buildIconContainer(
          icon: Icons.notifications,
          borderColor: Colors.transparent,
        );
    }
  }

  /// Builds the CHON logo icon container
  Widget _buildChonLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF151918),
        border: Border.all(
          color: const Color(0xFF00B894).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/chon_logo.png',
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'chon',
                style: TextStyle(
                  color: Color(0xFF00B894),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds a generic icon container
  Widget _buildIconContainer({
    required IconData icon,
    required Color borderColor,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF151918),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  /// Returns sample notification data for UI development
  List<AppNotification> _getSampleNotifications() {
    return [
      AppNotification(
        type: 'game',
        title: 'Game Name',
        message: 'The game has begun, Play, Win and Earn, Ruuuuuuuuuun',
        time: 'Friday 2:20pm',
        icon: 'chon',
        isHighlighted: false,
      ),
      AppNotification(
        type: 'game',
        title: 'Game Name',
        message:
            'Just a random text here, Just a random text here, Just a random text here, Just a random text here',
        time: 'Friday 2:20pm',
        icon: 'gamepad',
        isHighlighted: false,
      ),
      AppNotification(
        type: 'announcement',
        title: 'Coming Soon!',
        message:
            'Just a random text here, Just a random text here, Just a random text here, Just a random text here',
        time: 'Friday 2:20pm',
        icon: 'warning',
        isHighlighted: true,
      ),
      AppNotification(
        type: 'game',
        title: 'Game Name',
        message:
            'Just a random text here, Just a random text here, Just a random text here, Just a random text here',
        time: 'Friday 2:20pm',
        icon: 'chon',
        isHighlighted: false,
      ),
      AppNotification(
        type: 'game',
        title: 'Game Name',
        message:
            'Just a random text here, Just a random text here, Just a random text here, Just a random text here',
        time: 'Friday 2:20pm',
        icon: 'gamepad',
        isHighlighted: false,
      ),
      AppNotification(
        type: 'warning',
        title: 'Game Name',
        message:
            'Just a random text here, Just a random text here, Just a random text here, Just a random text here',
        time: 'Friday 2:20pm',
        icon: 'warning',
        isHighlighted: false,
      ),
      AppNotification(
        type: 'game',
        title: 'Game Name',
        message:
            'Just a random text here, Just a random text here, Just a random text here, Just a random text here',
        time: 'Friday 2:20pm',
        icon: 'chon',
        isHighlighted: false,
      ),
      AppNotification(
        type: 'game',
        title: 'Game Name',
        message:
            'Just a random text here, Just a random text here, Just a random text here, Just a random text here',
        time: 'Friday 2:20pm',
        icon: 'gamepad',
        isHighlighted: false,
      ),
      AppNotification(
        type: 'warning',
        title: 'Game Name',
        message:
            'Just a random text here, Just a random text here, Just a random text here, Just a random text here',
        time: 'Friday 2:20pm',
        icon: 'warning',
        isHighlighted: false,
      ),
    ];
  }
}
