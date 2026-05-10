import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/sound_manager.dart';
import '../widgets/app_drawer.dart';
import '../widgets/category_card.dart';
import '../widgets/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final SoundManager _soundManager = SoundManager();
  final bool _isInit = false;
  bool _showTips = true;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Start the animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    // Use the safer method that doesn't call notifyListeners during build
    quizProvider.loadCategoriesSafely(context);
    
    // Return a future that completes when categories are loaded
    return quizProvider.loadCategories();
  }
  
  // Calculate user level based on XP
  int _calculateLevel(int xp) {
    return (xp / 100).floor() + 1;
  }
  
  // Calculate progress to next level
  double _calculateProgress(int xp) {
    final currentLevelXp = ((_calculateLevel(xp) - 1) * 100);
    final nextLevelXp = currentLevelXp + 100;
    return (xp - currentLevelXp) / (nextLevelXp - currentLevelXp);
  }
  
  // Check if a category is unlocked based on user level
  bool _isCategoryUnlocked(Category category, int userLevel) {
    return userLevel >= category.requiredLevel;
  }
  
  // Get unlocked categories count
  int _getUnlockedCategoriesCount(List<Category> categories, int userLevel) {
    return categories.where((category) => _isCategoryUnlocked(category, userLevel)).length;
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<QuizProvider, AuthProvider>(
      builder: (context, quizProvider, authProvider, child) {
        final userProfile = authProvider.userProfile;
        final userXp = userProfile?.xp ?? 0;
        final userLevel = _calculateLevel(userXp);
        
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('Quiz Categories'),
            actions: [
              IconButton(
                onPressed: () {
                  context.push(AppConstants.profileRoute);
                },
                icon: const Icon(Icons.person),
              ),
              IconButton(
                onPressed: () {
                  context.push(AppConstants.settingsRoute);
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          drawer: const AppDrawer(),
          body: FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              )),
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: Column(
                  children: [
                    // XP and Level Card
                    _buildXpLevelCard(userXp, userLevel),
                    
                    // XP Tips for new users
                    if (_showTips && userLevel < 3)
                      _buildXpTipsCard(
                        unlockedCount: _getUnlockedCategoriesCount(
                          quizProvider.categories, 
                          userLevel
                        ),
                        totalCount: quizProvider.categories.length,
                      ),
                    
                    // Categories Grid
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (quizProvider.isLoading) {
                            return const LoadingIndicator();
                          }
                          
                          if (quizProvider.error.isNotEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Error loading categories',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.error,
                                      fontSize: AppConstants.subheadingFontSize,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadData,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          if (quizProvider.categories.isEmpty) {
                            return const Center(
                              child: Text('No categories available'),
                            );
                          }
                          
                          // Sort categories by required level
                          final sortedCategories = List<Category>.from(quizProvider.categories)
                            ..sort((a, b) => a.requiredLevel.compareTo(b.requiredLevel));
                          
                          return _buildCategoriesList(sortedCategories, userLevel);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildXpTipsCard(
    {required int unlockedCount, required int totalCount}
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Tips to earn XP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _showTips = false;
                      });
                    },
                  ),
                ],
              ),
              const Divider(),
              const Text(
                '• Complete quizzes to earn XP (10 XP per correct answer)',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                '• Try to get perfect scores for bonus XP',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '• You have unlocked $unlockedCount of $totalCount categories',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildXpLevelCard(int xp, int level) {
    final progress = _calculateProgress(xp);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$level',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$xp XP',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'XP Progress',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              // Background progress bar
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              // Foreground progress bar
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% to Level ${level + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              Text(
                'Next: ${level * 100 + (progress * 100).toInt()}/100',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoriesList(List<Category> categories, int userLevel) {
    // Add debug logging to show category count and names
    debugPrint('Found ${categories.length} categories: ${categories.map((c) => "${c.name} (Lvl ${c.requiredLevel})").join(", ")}');
    
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isUnlocked = _isCategoryUnlocked(category, userLevel);
        
        // Apply staggered animation
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.2;
            final startValue = delay;
            final endValue = 1.0;
            
            final animationProgress = _animationController.value;
            final calculatedValue = startValue + animationProgress * (endValue - startValue);
            final finalValue = calculatedValue.clamp(0.0, 1.0);
            
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(delay, 1.0, curve: Curves.easeOut),
                ),
              ),
              child: Transform.translate(
                offset: Offset(
                  0,
                  20 * (1 - finalValue),
                ),
                child: child,
              ),
            );
          },
          child: CategoryCard(
            category: category,
            isUnlocked: isUnlocked,
            onTap: () {
              _soundManager.playClickSound();
              Provider.of<QuizProvider>(context, listen: false).selectCategory(category);
              context.pushNamed(
                'category',
                extra: {
                  'id': category.id,
                },
              );
            },
          ),
        );
      },
    );
  }
} 