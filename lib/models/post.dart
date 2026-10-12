/// Simple model for a post from JSONPlaceholder.
class Post {
  final int id;
  final String title;
  final String body;

  const Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: (json['title'] ?? '').toString().trim(),
      body: (json['body'] ?? '').toString().trim(),
    );
  }

  /// Arguments passed to the details screen.
  Map<String, dynamic> toArguments() => {
    'id': id,
    'title': title,
    'body': body,
  };
}
