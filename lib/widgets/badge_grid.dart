import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'badge_item.dart';

class BadgeGrid extends StatelessWidget {
  final List<String> badges;
  final bool showEmpty;
  
  const BadgeGrid({
    super.key,
    required this.badges,
    this.showEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    final allBadges = AppConstants.badgeDescriptions;
    
    if (badges.isEmpty && !showEmpty) {
      return const Center(
        child: Text(
          'No badges earned yet. Complete quizzes to earn badges!',
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: allBadges.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (context, index) {
        final badgeName = allBadges.keys.elementAt(index);
        final badgeDescription = allBadges[badgeName] ?? '';
        final isEarned = badges.contains(badgeName);
        
        return BadgeItem(
          name: badgeName,
          imageUrl: '', // You would load actual badge image here
          description: badgeDescription,
          isEarned: isEarned,
          onTap: () {
            _showBadgeDetails(context, badgeName, badgeDescription, isEarned);
          },
        );
      },
    );
  }
  
  void _showBadgeDetails(
    BuildContext context, 
    String name, 
    String description, 
    bool isEarned
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEarned ? Icons.emoji_events : Icons.lock,
              size: 80,
              color: isEarned 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              isEarned 
                ? 'You have earned this badge!' 
                : 'Complete the challenge to earn this badge.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 