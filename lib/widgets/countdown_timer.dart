import 'package:flutter/material.dart';

class CountdownTimer extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  
  const CountdownTimer({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });
  
  @override
  Widget build(BuildContext context) {
    // Calculate progress percentage
    final progress = remainingSeconds / totalSeconds;
    
    // Determine color based on remaining time
    Color timerColor;
    if (progress > 0.6) {
      timerColor = Colors.green;
    } else if (progress > 0.3) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.red;
    }
    
    return SizedBox(
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Timer text
          Text(
            '$remainingSeconds s',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: timerColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
} 