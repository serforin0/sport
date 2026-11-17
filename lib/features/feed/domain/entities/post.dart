import 'package:sport/features/auth/domain/entities/user.dart';

class Comment {
  final String id;
  final User author;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });
}

class Post {
  final String id;
  final User author;
  final String description;
  final List<String> images;
  final String? videoUrl;
  final DateTime createdAt;
  final List<String> likes; // User IDs
  final List<String> likeNames;
  final List<Comment> comments;
  final String? location;
  final String? eventName;

  const Post({
    required this.id,
    required this.author,
    required this.description,
    this.images = const [],
    this.videoUrl,
    required this.createdAt,
    this.likes = const [],
    this.likeNames = const [],
    this.comments = const [],
    this.location,
    this.eventName,
  });

  String? get imageUrl => images.isNotEmpty ? images.first : null;

  bool isLikedBy(String userId) => likes.contains(userId);
  int get likeCount => likes.length;
  int get commentCount => comments.length;

  String get likeSummary {
    if (likeCount == 0) return '';
    final named = likeNames.where((n) => n.trim().isNotEmpty);
    final name = named.isNotEmpty ? named.first : 'Alguien';
    if (likeCount == 1) {
      return 'Le ha gustado a $name';
    }
    return 'Le ha gustado a $name y otros ${likeCount - 1} usuarios';
  }
}
