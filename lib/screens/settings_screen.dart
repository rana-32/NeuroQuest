import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../providers/providers.dart';
import '../utils/sound_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final soundManager = SoundManager();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          
          // Theme selector
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Column(
                children: [
                  ListTile(
                    title: const Text('Theme'),
                    trailing: DropdownButton<String>(
                      value: themeProvider.currentThemeType,
                      onChanged: (value) {
                        if (value == 'light') {
                          themeProvider.setLightTheme();
                        } else if (value == 'dark') {
                          themeProvider.setDarkTheme();
                        } else {
                          themeProvider.setKidsTheme();
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'light',
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: 'dark',
                          child: Text('Dark'),
                        ),
                        DropdownMenuItem(
                          value: 'kids',
                          child: Text('Kids'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          
          const _SectionHeader(title: 'Audio'),
          
          // Sound toggle
          StatefulBuilder(
            builder: (context, setState) {
              return SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Turn sound effects on or off'),
                value: soundManager.isSoundEnabled,
                onChanged: (value) {
                  soundManager.toggleSound();
                  setState(() {});
                  
                  if (value) {
                    soundManager.playClickSound();
                  }
                },
              );
            },
          ),
          
          const _SectionHeader(title: 'Account'),
          
          // Sign out button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ListTile(
                title: const Text('Sign Out'),
                leading: const Icon(Icons.exit_to_app),
                onTap: () {
                  _showSignOutConfirmation(context, authProvider);
                },
              );
            },
          ),
          
          const _SectionHeader(title: 'Data'),
          
          // Reset progress button
          ListTile(
            title: const Text('Reset Progress'),
            subtitle: const Text('Clear all quiz progress and badges'),
            leading: const Icon(Icons.delete_forever),
            onTap: () {
              _showResetProgressConfirmation(context);
            },
          ),
          
          const _SectionHeader(title: 'About'),
          
          // About app
          ListTile(
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            leading: const Icon(Icons.info),
          ),
          
          // Developer options - only shown in debug mode
          if (kDebugMode) ...[
            const _SectionHeader(title: 'Developer Options'),
            
            ListTile(
              title: const Text('Developer Tools'),
              subtitle: const Text('Seed database and development tools'),
              leading: const Icon(Icons.code),
              iconColor: Colors.purple,
              onTap: () {
                SoundManager().playClickSound();
                GoRouter.of(context).push(AppConstants.devRoute);
              },
            ),
          ],
        ],
      ),
    );
  }
  
  void _showSignOutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppConstants.splashRoute);
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
  
  void _showResetProgressConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'Are you sure you want to reset all progress? This will delete all your badges, XP, and quiz results. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement reset progress logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progress reset successfully'),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Kids Adventure',
      children: [
        const SizedBox(height: 16),
        const Text(
          'A fun educational quiz app for kids to learn while having fun! Explore different categories, earn badges, and track your progress.',
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({
    required this.title,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
} 