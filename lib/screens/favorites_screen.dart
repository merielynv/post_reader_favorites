import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/status_views.dart';
import 'edit_note_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    Box box,
    Map<String, dynamic> fav,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Remove favorite?'),
            content: Text(
              '"${fav['title']}" will be removed from your favorites.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await box.delete(fav['id']); // DELETE
      messenger.showSnackBar(
        const SnackBar(content: Text('Removed from Favorites.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box(kFavoritesBox);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: ValueListenableBuilder<Box>(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          // READ: list all saved posts
          final favorites =
              box.values
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList()
                ..sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

          if (favorites.isEmpty) {
            return const EmptyView(
              icon: Icons.favorite_border,
              message:
                  'No favorites yet.\nOpen a post and tap "Save to Favorites".',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final fav = favorites[index];
              final String note = (fav['note'] ?? '').toString();

              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        kRouteDetails,
                        arguments: {
                          'id': fav['id'],
                          'title': fav['title'],
                          'body': fav['body'],
                        },
                      ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${fav['id']}. ${fav['title']}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${fav['id']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                note.isEmpty ? 'No note yet.' : note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontStyle:
                                      note.isEmpty
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // UPDATE
                        IconButton(
                          tooltip: 'Edit note',
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditNoteScreen(favorite: fav),
                                ),
                              ),
                        ),
                        // DELETE
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.error,
                            size: 20,
                          ),
                          onPressed: () => _confirmDelete(context, box, fav),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
        },
      ),
    );
  }
}
