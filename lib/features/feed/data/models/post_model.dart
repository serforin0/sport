import '../../domain/entities/post.dart';
import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/core/network/url_utils.dart';

String? _string(dynamic v) => v?.toString();

DateTime _parseDate(dynamic v) {
  if (v == null) return DateTime.now();
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return DateTime.now();
  }
}

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.author,
    required super.content,
    required super.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> json) {
    return CommentModel(
      id: _string(json['id']) ?? '',
      author: UserModel.fromMap(Map<String, dynamic>.from(json['author'] as Map)),
      content: _string(json['content']) ?? '',
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }

  factory CommentModel.fromApi(Map<String, dynamic> json, {required String currentUserId}) {
    final authorRaw = json['author'] ?? json['user'];
    Map<String, dynamic> authorMap;
    if (authorRaw is Map) {
      authorMap = Map<String, dynamic>.from(authorRaw);
    } else {
      authorMap = {'id': '', 'email': '', 'name': 'Usuario'};
    }
    return CommentModel(
      id: _string(json['id']) ?? '',
      author: UserModel.fromMap(authorMap),
      content: _string(json['content'] ?? json['body']) ?? '',
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': (author as UserModel).toMap(),
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.author,
    required super.description,
    super.images,
    super.videoUrl,
    required super.createdAt,
    super.likes,
    super.comments,
    super.location,
    super.eventName,
  });

  factory PostModel.fromMap(Map<String, dynamic> json) {
    return PostModel(
      id: _string(json['id']) ?? '',
      author: UserModel.fromMap(Map<String, dynamic>.from(json['author'] as Map)),
      description: _string(json['description']) ?? '',
      images: List<String>.from(json['images'] ?? json['imageUrl'] != null ? [json['imageUrl']] : []),
      videoUrl: _string(json['videoUrl']),
      createdAt: DateTime.parse(json['createdAt'].toString()),
      likes: List<String>.from(json['likes'] ?? []),
      comments: (json['comments'] as List? ?? [])
          .map((e) => CommentModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      location: _string(json['location']),
      eventName: _string(json['eventName']),
    );
  }

  factory PostModel.fromApi(Map<String, dynamic> json, {required String currentUserId}) {
    final authorRaw = json['author'] ?? json['user'];
    final author = authorRaw is Map
        ? UserModel.fromMap(Map<String, dynamic>.from(authorRaw))
        : UserModel(id: '', email: '', name: 'Usuario');

    final description =
        _string(json['body'] ?? json['description'] ?? json['content'] ?? json['text']) ?? '';

    List<String> likes = [];
    final likesRaw = json['likes'] ?? json['liked_by'];
    if (likesRaw is List) {
      for (final e in likesRaw) {
        if (e is Map) {
          final id = e['id'] ?? e['user_id'];
          if (id != null) likes.add(id.toString());
        } else if (e != null) {
          likes.add(e.toString());
        }
      }
    }
    if (json['liked_by_me'] == true || json['is_liked'] == true) {
      if (!likes.contains(currentUserId)) likes = [...likes, currentUserId];
    }

    final comments = (json['comments'] as List? ?? [])
        .whereType<Map>()
        .map((e) => CommentModel.fromApi(Map<String, dynamic>.from(e), currentUserId: currentUserId))
        .toList();

    List<String> images = [];
    final singleImage = _string(json['image_url'] ?? json['imageUrl'] ?? json['attachment_url']);
    
    // Check for gallery or images array
    final gallery = json['gallery'] ?? json['images'] ?? json['attachments'];
    if (gallery is List && gallery.isNotEmpty) {
      for (final item in gallery) {
        String? url;
        if (item is Map) {
          url = _string(item['url'] ?? item['image_url'] ?? item['path'] ?? item['link']);
        } else {
          url = item.toString();
        }
        final resolved = UrlUtils.resolve(url);
        if (resolved != null) images.add(resolved);
      }
    } else if (singleImage != null) {
      final resolved = UrlUtils.resolve(singleImage);
      if (resolved != null) images.add(resolved);
    }

    return PostModel(
      id: _string(json['id']) ?? '',
      author: author,
      description: description,
      images: images,
      videoUrl: _string(json['video_url'] ?? json['videoUrl']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      likes: likes,
      comments: comments,
      location: _string(json['location'] ?? json['place']),
      eventName: _string(json['event_name'] ?? json['eventName']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': (author as UserModel).toMap(),
      'description': description,
      'images': images,
      'videoUrl': videoUrl,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments':
          comments.map((e) => (e as CommentModel).toMap()).toList(),
      'location': location,
      'eventName': eventName,
    };
  }
}
