class Story {
  final String id;
  final String? ownerUserId;
  final String displayName;
  final String? avatarUrl;
  final String mediaUrl;
  final String type;
  final bool isOwn;

  const Story({
    required this.id,
    this.ownerUserId,
    required this.displayName,
    this.avatarUrl,
    required this.mediaUrl,
    required this.type,
    this.isOwn = false,
  });
}
