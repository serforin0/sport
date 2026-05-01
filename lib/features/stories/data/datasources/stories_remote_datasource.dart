import 'package:dio/dio.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import '../../domain/entities/story.dart';
import 'package:sport/core/network/url_utils.dart';

class StoriesRemoteDataSource {
  final ApiClient apiClient;

  StoriesRemoteDataSource(this.apiClient);

  Options _auth(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  Future<List<Story>> fetchStories(String token) async {
    final response = await apiClient.get('/stories', options: _auth(token));
    final list = unwrapDataList(response.data);
    return list.whereType<Map>().map((e) => _parseStory(Map<String, dynamic>.from(e))).toList();
  }

  Story _parseStory(Map<String, dynamic> json) {
    final user = json['user'];
    String name = 'Usuario';
    String? avatar;
    String? userId;
    if (user is Map) {
      final u = Map<String, dynamic>.from(user);
      userId = u['id']?.toString();
      name = u['name']?.toString() ??
          '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
      if (name.isEmpty) name = 'Usuario';
      avatar = u['avatar']?.toString() ?? u['avatar_url']?.toString() ?? u['photo_url']?.toString();
    }
    return Story(
      id: json['id']?.toString() ?? '',
      ownerUserId: userId,
      displayName: name,
      avatarUrl: UrlUtils.resolve(avatar ?? json['avatar_url']?.toString()),
      mediaUrl: UrlUtils.resolve(json['media_url']?.toString() ?? json['url']?.toString() ?? json['image_url']?.toString() ?? json['file_url']?.toString() ?? '') ?? '',
      type: (json['type'] ?? 'image').toString(),
      isOwn: json['is_own'] == true || json['mine'] == true,
    );
  }

  Future<void> createStory(String token, {String? mediaUrl, String? filePath, required String type}) async {
    final formData = FormData.fromMap({
      'type': type,
      if (mediaUrl != null) 'media_url': mediaUrl,
    });

    if (filePath != null) {
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(filePath, filename: 'story_media.${type == 'video' ? 'mp4' : 'jpg'}'),
      ));
    }

    await apiClient.post(
      '/stories',
      data: formData,
      options: _auth(token),
    );
  }

}
