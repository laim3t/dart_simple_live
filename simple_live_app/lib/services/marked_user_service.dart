import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/models/db/marked_user.dart';
import 'package:simple_live_app/models/db/marked_user_danmaku.dart';
import 'package:simple_live_app/services/db_service.dart';
import 'package:uuid/uuid.dart';

/// 特别标记用户：高亮 + 记录弹幕
class MarkedUserService extends GetxService {
  static MarkedUserService get instance => Get.find<MarkedUserService>();

  final Uuid _uuid = const Uuid();

  /// 飞屏/聊天列表高亮颜色
  static const Color highlightColor = Color(0xFFFF9800);

  /// 单用户记录条数上限
  static const int maxRecordsPerUser = 2000;

  /// 全局记录总上限
  static const int maxRecordsTotal = 10000;

  final RxList<MarkedUser> markedUsers = <MarkedUser>[].obs;

  Future<MarkedUserService> init() async {
    await reload();
    return this;
  }

  Future<void> reload() async {
    markedUsers.assignAll(DBService.instance.getMarkedUserList());
  }

  static String buildId(String siteId, String userId) => '${siteId}_$userId';

  MarkedUser? getMarkedUser(String siteId, String userId) {
    if (userId.isEmpty) return null;
    return DBService.instance.getMarkedUser(buildId(siteId, userId));
  }

  /// 当前直播间是否应对该用户高亮
  bool shouldHighlight(String siteId, String userId, String roomId) {
    final user = getMarkedUser(siteId, userId);
    if (user == null || !user.highlight) return false;
    return user.appliesToRoom(roomId);
  }

  /// 当前直播间是否应记录该用户弹幕
  bool shouldRecord(String siteId, String userId, String roomId) {
    final user = getMarkedUser(siteId, userId);
    if (user == null || !user.record) return false;
    return user.appliesToRoom(roomId);
  }

  Future<void> saveMarkedUser({
    required String siteId,
    required String userId,
    required String userName,
    required bool highlight,
    required bool record,
    required int scope,
    required String roomId,
  }) async {
    final id = buildId(siteId, userId);
    final existing = DBService.instance.getMarkedUser(id);
    final now = DateTime.now();

    // 高亮与记录都关闭时，删除标记
    if (!highlight && !record) {
      await removeMarkedUser(id, deleteHistory: false);
      return;
    }

    final user = MarkedUser(
      id: id,
      siteId: siteId,
      userId: userId,
      userName: userName,
      highlight: highlight,
      record: record,
      scope: scope,
      roomId: scope == MarkedUserScope.room ? roomId : '',
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await DBService.instance.addOrUpdateMarkedUser(user);
    await reload();
  }

  Future<void> removeMarkedUser(
    String id, {
    bool deleteHistory = false,
  }) async {
    final user = DBService.instance.getMarkedUser(id);
    await DBService.instance.deleteMarkedUser(id);
    if (deleteHistory && user != null) {
      await DBService.instance.deleteDanmakuByUser(user.siteId, user.userId);
    }
    await reload();
  }

  Future<void> setHighlight(String id, bool value) async {
    final user = DBService.instance.getMarkedUser(id);
    if (user == null) return;
    user.highlight = value;
    user.updatedAt = DateTime.now();
    if (!user.highlight && !user.record) {
      await removeMarkedUser(id, deleteHistory: false);
      return;
    }
    await DBService.instance.addOrUpdateMarkedUser(user);
    await reload();
  }

  Future<void> setRecord(String id, bool value) async {
    final user = DBService.instance.getMarkedUser(id);
    if (user == null) return;
    user.record = value;
    user.updatedAt = DateTime.now();
    if (!user.highlight && !user.record) {
      await removeMarkedUser(id, deleteHistory: false);
      return;
    }
    await DBService.instance.addOrUpdateMarkedUser(user);
    await reload();
  }

  Future<void> recordDanmaku({
    required String siteId,
    required String userId,
    required String userName,
    required String content,
    required String roomId,
    String roomTitle = '',
    DateTime? sentAt,
  }) async {
    if (userId.isEmpty || content.isEmpty) return;
    if (!shouldRecord(siteId, userId, roomId)) return;

    final item = MarkedUserDanmaku(
      id: _uuid.v4(),
      siteId: siteId,
      userId: userId,
      userName: userName,
      content: content,
      sentAt: sentAt ?? DateTime.now(),
      roomId: roomId,
      roomTitle: roomTitle,
    );
    await DBService.instance.addMarkedUserDanmaku(item);
    await DBService.instance.trimDanmakuForUser(
      siteId,
      userId,
      maxRecordsPerUser,
    );
    await DBService.instance.trimDanmakuTotal(maxRecordsTotal);
  }

  List<MarkedUserDanmaku> getDanmakuByUser(String siteId, String userId) {
    return DBService.instance.getDanmakuByUser(siteId, userId);
  }

  Future<void> clearDanmakuByUser(String siteId, String userId) async {
    await DBService.instance.deleteDanmakuByUser(siteId, userId);
  }

  Future<void> clearAllDanmaku() async {
    await DBService.instance.clearAllMarkedUserDanmaku();
  }
}
