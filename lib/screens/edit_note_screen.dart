import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants.dart';
import '../theme/app_theme.dart';

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic> favorite;

  const EditNoteScreen({super.key, required this.favorite});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  static const int _maxLength = 200;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: (widget.favorite['note'] ?? '').toString(),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final Box box = Hive.box(kFavoritesBox);

    // UPDATE: save the changed note back into the box
    await box.put(widget.favorite['id'], {
      ...widget.favorite,
      'note': _noteController.text.trim(),
    });

    messenger.showSnackBar(const SnackBar(content: Text('Note saved!')));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final fav = widget.favorite;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Note')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Post Title',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  '${fav['title']}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  'ID: ${fav['id']}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Your Note',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 6,
            maxLength: _maxLength,
            decoration: const InputDecoration(
              hintText: 'Write a short personal note...',
              fillColor: AppColors.surface,
            ),
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) => Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$currentLength/$maxLength',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _saveNote, child: const Text('Save')),
        ],
      ),
    );
  }
}
