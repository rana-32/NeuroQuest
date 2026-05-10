import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final int age;
  final VoidCallback onEditPressed;
  
  const ProfileHeader({
    super.key,
    required this.name,
    required this.age,
    required this.onEditPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Profile avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Profile name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '($age years old)',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onEditPressed,
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Profile',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 