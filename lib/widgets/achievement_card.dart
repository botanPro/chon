import 'package:flutter/material.dart';
import '../main.dart';

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final double progress; // 0.0 to 1.0

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
    this.progress = 0.0,
  });
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppDesign.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: achievement.unlocked
                ? AppDesign.primaryColor.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Achievement icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: achievement.unlocked
                      ? AppDesign.primaryColor.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: achievement.unlocked
                        ? AppDesign.primaryColor
                        : Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.unlocked
                      ? AppDesign.primaryColor
                      : Colors.white.withOpacity(0.3),
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              // Achievement details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      achievement.title,
                      style: TextStyle(
                        color: achievement.unlocked
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      achievement.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Progress bar
                    if (!achievement.unlocked && achievement.progress > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: achievement.progress,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppDesign.primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            minHeight: 6,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(achievement.progress * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Status icon
              if (achievement.unlocked)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppDesign.primaryColor,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AchievementsList extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsList({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return AchievementCard(
          achievement: achievements[index],
          onTap: () {
            // Show achievement details
            _showAchievementDetails(context, achievements[index]);
          },
        );
      },
    );
  }

  void _showAchievementDetails(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppDesign.elevatedSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: achievement.unlocked
                ? AppDesign.primaryColor.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        title: Text(
          achievement.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Achievement icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: achievement.unlocked
                    ? AppDesign.primaryColor.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: achievement.unlocked
                      ? AppDesign.primaryColor
                      : Colors.white.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Icon(
                achievement.icon,
                color: achievement.unlocked
                    ? AppDesign.primaryColor
                    : Colors.white.withOpacity(0.3),
                size: 40,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 16),

            // Status
            Text(
              achievement.unlocked
                  ? 'Achievement Unlocked!'
                  : 'Achievement Locked',
              style: TextStyle(
                color: achievement.unlocked
                    ? AppDesign.primaryColor
                    : Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            // Progress bar
            if (!achievement.unlocked && achievement.progress > 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: achievement.progress,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppDesign.primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(achievement.progress * 100).toInt()}% Complete',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
