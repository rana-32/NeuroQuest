import 'package:flutter/material.dart';

class QuestionProgress extends StatelessWidget {
  final int current;
  final int total;
  
  const QuestionProgress({
    super.key,
    required this.current,
    required this.total,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress text
        Text(
          'Question $current of $total',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: current / total,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
} 