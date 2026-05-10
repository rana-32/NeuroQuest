import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../providers/providers.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final userProfile = authProvider.userProfile;
          
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Drawer header with user info
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User avatar
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        userProfile?.name.isNotEmpty == true 
                            ? userProfile!.name[0].toUpperCase() 
                            : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // User name
                    Text(
                      userProfile?.name ?? 'Player',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    // User XP
                    if (userProfile != null)
                      Text(
                        'XP: ${userProfile.xp}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Home
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppConstants.homeRoute);
                },
              ),
              
              // Profile
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppConstants.profileRoute);
                },
              ),
              
              // Settings
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppConstants.settingsRoute);
                },
              ),
              
              const Divider(),
              
              // Sign out
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Sign Out'),
                onTap: () {
                  _confirmSignOut(context, authProvider);
                },
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _confirmSignOut(BuildContext context, AuthProvider authProvider) {
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
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close drawer
                context.go(AppConstants.splashRoute);
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
} 