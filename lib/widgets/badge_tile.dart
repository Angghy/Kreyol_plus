import 'package:flutter/material.dart' hide Badge;
import '../models/badge.dart';

class BadgeTile extends StatelessWidget {
  final Badge badge;
  final bool isUnlocked;

  const BadgeTile({
    Key? key,
    required this.badge,
    required this.isUnlocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: isUnlocked ? 4 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isUnlocked ? Colors.yellow.shade50 : Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked ? Colors.yellow.shade200 : Colors.grey.shade300,
              ),
              child: badge.iconPath.isNotEmpty
                  ? ClipOval(
                      child: Image.asset(
                        badge.iconPath,
                        fit: BoxFit.cover,
                        color: isUnlocked ? null : Colors.grey,
                        colorBlendMode: isUnlocked ? null : BlendMode.saturation,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.emoji_events,
                          size: 32,
                          color: isUnlocked ? Colors.orange : Colors.grey,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.emoji_events,
                      size: 32,
                      color: isUnlocked ? Colors.orange : Colors.grey,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isUnlocked ? Colors.black : Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isUnlocked ? Colors.black54 : Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            if (isUnlocked)
              const Icon(
                Icons.lock_open,
                color: Colors.green,
              ),
            if (!isUnlocked)
              const Icon(
                Icons.lock,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}


