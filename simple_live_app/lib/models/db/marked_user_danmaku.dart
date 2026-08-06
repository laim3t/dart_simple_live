import 'package:hive/hive.dart';

part 'marked_user_danmaku.g.dart';

@HiveType(typeId: 5)
class MarkedUserDanmaku {
  MarkedUserDanmaku({
    required this.id,
    required this.siteId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.sentAt,
    required this.roomId,
    this.roomTitle = '',
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String siteId;

  @HiveField(2)
  String userId;

  @HiveField(3)
  String userName;

  @HiveField(4)
  String content;

  @HiveField(5)
  DateTime sentAt;

  @HiveField(6)
  String roomId;

  @HiveField(7)
  String roomTitle;

  String get userKey => '${siteId}_$userId';

  factory MarkedUserDanmaku.fromJson(Map<String, dynamic> json) =>
      MarkedUserDanmaku(
        id: json['id'],
        siteId: json['siteId'],
        userId: json['userId'],
        userName: json['userName'],
        content: json['content'],
        sentAt: DateTime.parse(json['sentAt']),
        roomId: json['roomId'] ?? '',
        roomTitle: json['roomTitle'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'siteId': siteId,
        'userId': userId,
        'userName': userName,
        'content': content,
        'sentAt': sentAt.toString(),
        'roomId': roomId,
        'roomTitle': roomTitle,
      };
}
