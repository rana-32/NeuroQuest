import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kids_adventure/utils/database_seeder.dart';
import 'package:kids_adventure/utils/advanced_seeder.dart';
import 'package:kids_adventure/utils/sound_manager.dart';

/// Development-only screen with utilities for debugging and development
/// This screen should never be accessible in production builds
class DevScreen extends StatefulWidget {
  const DevScreen({super.key});

  @override
  State<DevScreen> createState() => _DevScreenState();
}

class _DevScreenState extends State<DevScreen> {
  final DatabaseSeeder _seeder = DatabaseSeeder();
  final AdvancedSeeder _advancedSeeder = AdvancedSeeder();
  bool _isLoading = false;
  String _statusMessage = '';
  int _questionsPerCategory = 50;
  bool _includeExplanations = true;
  
  @override
  void initState() {
    super.initState();
    
    // Safety check - don't allow this screen in production
    if (!kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }
  }
  
  Future<void> _seedDatabase() async {
    final SoundManager soundManager = SoundManager();
    
    setState(() {
      _isLoading = true;
      _statusMessage = 'Seeding database...';
    });
    
    try {
      await _seeder.seedQuizData();
      soundManager.playCorrectSound();
      setState(() {
        _statusMessage = 'Database seeded successfully!';
      });
    } catch (e) {
      soundManager.playWrongSound();
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _forceReseed() async {
    final SoundManager soundManager = SoundManager();
    
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text(
          'This will delete all existing quiz data and create new seed data. '
          'This operation cannot be undone. Continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Proceed', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() {
      _isLoading = true;
      _statusMessage = 'Reseeding database...';
    });
    
    try {
      await _seeder.forceReseed();
      soundManager.playCorrectSound();
      setState(() {
        _statusMessage = 'Database reseeded successfully!';
      });
    } catch (e) {
      soundManager.playWrongSound();
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _seedLargeDatabase() async {
    final SoundManager soundManager = SoundManager();
    
    // Create a new advanced seeder with the current settings
    final advancedSeeder = AdvancedSeeder(
      questionsPerCategory: _questionsPerCategory,
      includeExplanations: _includeExplanations,
    );
    
    setState(() {
      _isLoading = true;
      _statusMessage = 'Seeding large dataset with $_questionsPerCategory questions per category...';
    });
    
    try {
      await advancedSeeder.seedLargeQuizData();
      soundManager.playCorrectSound();
      setState(() {
        _statusMessage = 'Large dataset seeded successfully!';
      });
    } catch (e) {
      soundManager.playWrongSound();
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _forceReseedLarge() async {
    final SoundManager soundManager = SoundManager();
    
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: Text(
          'This will delete all existing quiz data and create $_questionsPerCategory questions per category. '
          'This operation cannot be undone and may take some time. Continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Proceed', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    // Create a new advanced seeder with the current settings
    final advancedSeeder = AdvancedSeeder(
      questionsPerCategory: _questionsPerCategory,
      includeExplanations: _includeExplanations,
    );
    
    setState(() {
      _isLoading = true;
      _statusMessage = 'Force reseeding large dataset...';
    });
    
    try {
      await advancedSeeder.forceReseedLarge();
      soundManager.playCorrectSound();
      setState(() {
        _statusMessage = 'Large dataset reseeded successfully!';
      });
    } catch (e) {
      soundManager.playWrongSound();
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _forceUpdateCategories() async {
    final SoundManager soundManager = SoundManager();
    
    setState(() {
      _isLoading = true;
      _statusMessage = 'Updating all categories...';
    });
    
    try {
      await _advancedSeeder.forceUpdateCategories();
      soundManager.playCorrectSound();
      setState(() {
        _statusMessage = 'All categories updated successfully!';
      });
    } catch (e) {
      soundManager.playWrongSound();
      setState(() {
        _statusMessage = 'Error updating categories: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safety check for production builds
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(
          child: Text('This screen is not available in production'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Tools'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              color: Colors.amber,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  '⚠️ DEVELOPMENT MODE ONLY ⚠️\n'
                  'These tools should never be used in production!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Database Seeding Section
            const Text(
              'Database Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            
            // Basic seeding card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Quiz Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Seed the database with basic quiz categories and questions. '
                      'This will only add data if the database is empty.',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _seedDatabase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Seed Basic Quiz Data'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Force Basic Reseed (Danger!)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Delete all quiz data and create new basic seed data. '
                      'This operation cannot be undone!',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _forceReseed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Force Basic Reseed'),
                    ),
                    
                    // Add category update button
                    const SizedBox(height: 16),
                    const Text(
                      'Update All Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Force update all category definitions to show all 8 categories. '
                      'Use this if some categories are missing.',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _forceUpdateCategories,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Update All Categories'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Advanced seeding card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Large Quiz Dataset',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Seed the database with a large set of generated quiz questions. '
                      'Useful for performance testing and showcasing a fully populated app.',
                    ),
                    const SizedBox(height: 16),
                    
                    // Settings section
                    Row(
                      children: [
                        const Text('Questions per category:'),
                        const SizedBox(width: 10),
                        DropdownButton<int>(
                          value: _questionsPerCategory,
                          onChanged: _isLoading ? null : (value) {
                            if (value != null) {
                              setState(() {
                                _questionsPerCategory = value;
                              });
                            }
                          },
                          items: [20, 50, 100, 200, 500].map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    CheckboxListTile(
                      title: const Text('Include Explanations'),
                      value: _includeExplanations,
                      onChanged: _isLoading ? null : (value) {
                        if (value != null) {
                          setState(() {
                            _includeExplanations = value;
                          });
                        }
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _seedLargeDatabase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Seed Large Dataset'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Force Large Dataset Reseed (Danger!)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Delete all existing quiz data and create a large dataset. '
                      'This operation cannot be undone and may take some time!',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _forceReseedLarge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Force Large Dataset Reseed'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Status section
            if (_statusMessage.isNotEmpty)
              Card(
                color: _statusMessage.contains('Error')
                    ? Colors.red.shade100
                    : Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusMessage.contains('Error') 
                            ? 'Error Status' 
                            : 'Status',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_statusMessage),
                    ],
                  ),
                ),
              ),
            
            // Loading indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 