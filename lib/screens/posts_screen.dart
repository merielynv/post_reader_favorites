import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import '../widgets/add_post_dialog.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/result_dialog.dart';
import '../widgets/status_views.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Post> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _fetchPosts(); // async method called from initState()
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- GET
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse(kPostsUrl))
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _posts =
              data
                  .map((e) => Post.fromJson(e as Map<String, dynamic>))
                  .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Server responded with status code ${response.statusCode}. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Unable to fetch posts. Please check your internet connection and try again.';
        _isLoading = false;
      });
    }
  }

  // --------------------------------------------------------------- POST
  Future<void> _showAddPostDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const AddPostDialog(),
    );
    if (result == null) return;
    await _createPost(result['title']!, result['body']!);
  }

  Future<void> _createPost(String title, String body) async {
    bool success = false;
    String message;

    try {
      final response = await http.post(
        Uri.parse(kPostsUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
      );
      success = response.statusCode == 201;
      message =
          success
              ? 'Post added successfully!'
              : 'Failed to add post (status code ${response.statusCode}).';
    } catch (e) {
      message = 'Failed to add post. Please check your internet connection.';
    }

    if (!mounted) return;
    await showResultDialog(context, success: success, message: message);
  }

  // ------------------------------------------------------------- BUILD
  List<Post> get _filteredPosts {
    if (_query.isEmpty) return _posts;
    final q = _query.toLowerCase();
    return _posts.where((p) => p.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Splash-style loading screen (no app bar), like the design.
    if (_isLoading) {
      return const Scaffold(body: LoadingView());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite, color: AppColors.accent),
            onPressed: () => Navigator.pushNamed(context, kRouteFavorites),
          ),
        ],
      ),
      body:
          _errorMessage != null
              ? ErrorView(message: _errorMessage!, onRetry: _fetchPosts)
              : _buildPostList(),
      floatingActionButton:
          _errorMessage == null
              ? FloatingActionButton(
                onPressed: _showAddPostDialog,
                child: const Icon(Icons.add, size: 30),
              )
              : null,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, kRouteFavorites);
        },
      ),
    );
  }

  Widget _buildPostList() {
    final posts = _filteredPosts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: 'Search posts...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              suffixIcon:
                  _query.isEmpty
                      ? null
                      : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
            ),
          ),
        ),
        Expanded(
          child:
              posts.isEmpty
                  ? const EmptyView(
                    icon: Icons.search_off,
                    message: 'No posts match your search.',
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          title: Text(
                            '${post.id}. ${post.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              post.body.replaceAll('\n', ' '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                          // Pass id, title and body as arguments
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                kRouteDetails,
                                arguments: post.toArguments(),
                              ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
