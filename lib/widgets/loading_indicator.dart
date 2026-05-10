import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final String message;
  final bool useLottie;

  const LoadingIndicator({
    super.key,
    this.size = 100,
    this.message = 'Loading...',
    this.useLottie = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (useLottie)
            SizedBox(
              height: size,
              width: size,
              child: Lottie.asset(
                'assets/animations/loading.json',
                repeat: true,
              ),
            )
          else
            SizedBox(
              height: size / 2,
              width: size / 2,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 4,
              ),
            ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
} 