import 'package:flutter/material.dart';

class XpProgress extends StatelessWidget {
  final int currentXp;
  final int earnedXp;
  final int nextMilestone;
  
  const XpProgress({
    super.key,
    required this.currentXp,
    required this.earnedXp,
    required this.nextMilestone,
  });
  
  @override
  Widget build(BuildContext context) {
    final previousXp = currentXp - earnedXp;
    final previousProgress = previousXp / nextMilestone;
    final currentProgress = currentXp / nextMilestone;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // XP progress title
            const Text(
              'XP Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // XP values
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$previousXp XP',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  '+$earnedXp',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  '$currentXp XP',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Progress bar
            Stack(
              children: [
                // Background progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: previousProgress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey.shade500,
                    ),
                    minHeight: 16,
                  ),
                ),
                
                // Foreground progress bar (with animation)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: previousProgress.clamp(0.0, 1.0),
                    end: currentProgress.clamp(0.0, 1.0),
                  ),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary,
                        ),
                        minHeight: 16,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Progress to next milestone
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current: $currentXp XP',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Next: $nextMilestone XP',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Progress: ${(currentProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 