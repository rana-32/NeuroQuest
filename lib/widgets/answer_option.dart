import 'package:flutter/material.dart';

class AnswerOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isDisabled;
  final VoidCallback onTap;

  const AnswerOption({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    
    if (isDisabled) {
      if (isCorrect) {
        // Correct answer
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green.shade800;
      } else if (isSelected) {
        // Incorrect selected answer
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
      } else {
        // Other answers when disabled
        backgroundColor = Theme.of(context).colorScheme.surface;
        borderColor = Theme.of(context).colorScheme.outline.withOpacity(0.3);
        textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
      }
    } else if (isSelected) {
      // Selected but not yet checked
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
      borderColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.primary;
    } else {
      // Unselected answer
      backgroundColor = Theme.of(context).colorScheme.surface;
      borderColor = Theme.of(context).colorScheme.outline.withOpacity(0.3);
      textColor = Theme.of(context).colorScheme.onSurface;
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected || isCorrect ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Option marker (A, B, C, D)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected || isCorrect 
                    ? borderColor 
                    : borderColor.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + (text.hashCode % 4)),
                  style: TextStyle(
                    color: isSelected || isCorrect 
                        ? Colors.white 
                        : borderColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Answer text
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            
            // Indicator icon
            if (isDisabled)
              Icon(
                isCorrect 
                    ? Icons.check_circle 
                    : isSelected 
                        ? Icons.cancel 
                        : null,
                color: isCorrect ? Colors.green : isSelected ? Colors.red : null,
              ),
          ],
        ),
      ),
    );
  }
} 