import 'package:hive/hive.dart';

part 'marked_user.g.dart';

/// 标记用户作用范围
class MarkedUserScope {
  static const int global = 0;
  static const int room = 1;
}

@HiveType(typeId: 4)
class MarkedUser {
  MarkedUser({
    required this.id,
    required this.siteId,
    required this.userId,
    required this.userName,
    required this.highlight,
    required this.record,
    required this.scope,
    required this.roomId,
    required this.createdAt,
    this.updatedAt,
  });

  /// id = siteId_userId
  @HiveField(0)
  String id;

  @HiveField(1)
  String siteId;

  @HiveField(2)
  String userId;

  @HiveField(3)
  String userName;

  /// 是否高亮该用户后续弹幕
  @HiveField(4)
  bool highlight;

  /// 是否记录该用户后续弹幕
  @HiveField(5)
  bool record;

  /// 0=全局 1=仅当前直播间
  @HiveField(6)
  int scope;

  /// scope=room 时有效
  @HiveField(7)
  String roomId;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime? updatedAt;

  bool get isGlobal => scope == MarkedUserScope.global;

  bool get isRoom => scope == MarkedUserScope.room;

  /// 在指定直播间是否生效
  bool appliesToRoom(String currentRoomId) {
    if (isGlobal) return true;
    return roomId == currentRoomId;
  }

  factory MarkedUser.fromJson(Map<String, dynamic> json) => MarkedUser(
        id: json['id'],
        siteId: json['siteId'],
        userId: json['userId'],
        userName: json['userName'],
        highlight: json['highlight'] ?? false,
        record: json['record'] ?? false,
        scope: json['scope'] ?? MarkedUserScope.global,
        roomId: json['roomId'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'siteId': siteId,
        'userId': userId,
        'userName': userName,
        'highlight': highlight,
        'record': record,
        'scope': scope,
        'roomId': roomId,
        'createdAt': createdAt.toString(),
        'updatedAt': updatedAt?.toString(),
      };
}
