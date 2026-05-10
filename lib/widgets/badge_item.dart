import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BadgeItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String description;
  final bool isEarned;
  final VoidCallback? onTap;
  
  const BadgeItem({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.description,
    this.isEarned = true,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Center(
                      child: imageUrl.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.emoji_events, size: 40),
                              ),
                            )
                          : Icon(
                              Icons.emoji_events,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Badge Name
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    // Badge Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Lock overlay for unearned badges
            if (!isEarned)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock,
                      size: 40,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 