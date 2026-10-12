import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants.dart';
import '../theme/app_theme.dart';

class PostDetailsScreen extends StatelessWidget {
  const PostDetailsScreen({super.key});

  Future<void> _saveToFavorites(
    BuildContext context,
    Box box,
    int id,
    String title,
    String body,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    // Same post id is used as the key, so a post is never saved twice.
    if (box.containsKey(id)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('This post is already in Favorites.')),
      );
      return;
    }

    await box.put(id, {'id': id, 'title': title, 'body': body, 'note': ''});

    messenger.showSnackBar(
      const SnackBar(content: Text('Post saved to Favorites!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the arguments passed from the Posts / Favorites screen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int id = args['id'] as int;
    final String title = args['title'] as String;
    final String body = args['body'] as String;

    final Box box = Hive.box(kFavoritesBox);

    return ValueListenableBuilder<Box>(
      valueListenable: box.listenable(keys: [id]),
      builder: (context, box, _) {
        final bool isSaved = box.containsKey(id);
        final saved = isSaved ? Map<String, dynamic>.from(box.get(id)) : null;
        final String note = (saved?['note'] ?? '').toString();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Post Details'),
            actions: [
              IconButton(
                tooltip: 'Save to Favorites',
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.accent,
                ),
                onPressed:
                    () => _saveToFavorites(context, box, id, title, body),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$id. $title',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: $id',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      body,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_note, color: AppColors.accent),
                          SizedBox(width: 8),
                          Text(
                            'My Note',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(note, style: const TextStyle(height: 1.4)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed:
                    isSaved
                        ? () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('This post is already in Favorites.'),
                          ),
                        )
                        : () => _saveToFavorites(context, box, id, title, body),
                icon: Icon(isSaved ? Icons.check : Icons.favorite),
                label: Text(
                  isSaved ? 'Saved to Favorites' : 'Save to Favorites',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
