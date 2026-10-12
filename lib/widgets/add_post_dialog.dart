import 'package:flutter/material.dart';

/// Dialog with Title and Body fields. Neither may be empty.
/// Pops with {'title': ..., 'body': ...} when "Post" is pressed.
class AddPostDialog extends StatefulWidget {
  const AddPostDialog({super.key});

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      title: Row(
        children: [
          const Expanded(
            child: Text(
              'Add New Post',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Title'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Enter post title'),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Title cannot be empty'
                            : null,
              ),
              const SizedBox(height: 16),
              const Text('Body'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bodyController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Enter post body'),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Body cannot be empty'
                            : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 42)),
          child: const Text('Post'),
        ),
      ],
    );
  }
}
