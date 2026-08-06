import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:simple_live_app/models/db/follow_user.dart';
import 'package:simple_live_app/models/db/follow_user_tag.dart';
import 'package:simple_live_app/models/db/history.dart';
import 'package:simple_live_app/models/db/marked_user.dart';
import 'package:simple_live_app/models/db/marked_user_danmaku.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

class DBService extends GetxService {
  static DBService get instance => Get.find<DBService>();
  late Box<History> historyBox;
  late Box<FollowUser> followBox;
  late Box<FollowUserTag> tagBox;
  late Box<MarkedUser> markedUserBox;
  late Box<MarkedUserDanmaku> markedUserDanmakuBox;
  final Uuid uuid = const Uuid();

  Future init() async {
    historyBox = await Hive.openBox("History");
    followBox = await Hive.openBox("FollowUser");
    tagBox = await Hive.openBox("FollowUserTag");
    markedUserBox = await Hive.openBox("MarkedUser");
    markedUserDanmakuBox = await Hive.openBox("MarkedUserDanmaku");
  }

  // follow_user_tag 相关逻辑
  bool getFollowTagExist(String id) {
    return tagBox.containsKey(id);
  }

  // 删除标签
  Future deleteFollowTag(String id) async {
    await tagBox.delete(id);
  }

  FollowUserTag? getFollowTag(String tag) {
    return tagBox.values.firstWhereOrNull((item) => item.tag == tag);
  }

  // 判断标签名称是否重复
  bool getFollowTagExistByTag(String tag) {
    return tagBox.values.any((item) => item.tag == tag);
  }

  // 获取标签列表
  List<FollowUserTag> getFollowTagList() {
    return tagBox.values.toList();
  }

  // 修改标签
  Future updateFollowTag(FollowUserTag followTag) async {
    await tagBox.put(followTag.id, followTag);
  }

  // 添加标签
  Future<FollowUserTag> addFollowTag(String tag) async {
    // 限制标签唯一且长度不超过8个字符
    if (getFollowTagExistByTag(tag) && tag.length > 8) {
      return getFollowTag(tag)!;
    }
    final String uniqueId = uuid.v4();
    final followUserTag = FollowUserTag(id: uniqueId, tag: tag, userId: []);
    await tagBox.put(uniqueId, followUserTag);
    return followUserTag;
  }

  // 调整标签顺序
  Future updateFollowTagOrder(List<FollowUserTag> userTagList) async {
    final Map<int, FollowUserTag> updatedMap = {
      for (int i = 0; i < userTagList.length; i++) i: userTagList[i]
    };
    await tagBox.clear();
    await tagBox.putAll(updatedMap);
  }

  bool getFollowExist(String id) {
    return followBox.containsKey(id);
  }

  List<FollowUser> getFollowList() {
    return followBox.values.toList();
  }

  Future addFollow(FollowUser follow) async {
    await followBox.put(follow.id, follow);
  }

  Future deleteFollow(String id) async {
    await followBox.delete(id);
  }

  History? getHistory(String id) {
    if (historyBox.containsKey(id)) {
      return historyBox.get(id);
    }
    return null;
  }

  Future addOrUpdateHistory(History history) async {
    await historyBox.put(history.id, history);
  }

  List<History> getHistores() {
    var his = historyBox.values.toList();
    his.sort((a, b) => b.updateTime.compareTo(a.updateTime));
    return his;
  }

  // ---------- MarkedUser ----------
  MarkedUser? getMarkedUser(String id) {
    if (markedUserBox.containsKey(id)) {
      return markedUserBox.get(id);
    }
    return null;
  }

  List<MarkedUser> getMarkedUserList() {
    final list = markedUserBox.values.toList();
    list.sort((a, b) =>
        (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt));
    return list;
  }

  Future addOrUpdateMarkedUser(MarkedUser user) async {
    await markedUserBox.put(user.id, user);
  }

  Future deleteMarkedUser(String id) async {
    await markedUserBox.delete(id);
  }

  // ---------- MarkedUserDanmaku ----------
  Future addMarkedUserDanmaku(MarkedUserDanmaku item) async {
    await markedUserDanmakuBox.put(item.id, item);
  }

  List<MarkedUserDanmaku> getDanmakuByUser(String siteId, String userId) {
    final list = markedUserDanmakuBox.values
        .where((e) => e.siteId == siteId && e.userId == userId)
        .toList();
    list.sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return list;
  }

  Future deleteDanmakuByUser(String siteId, String userId) async {
    final keys = markedUserDanmakuBox.keys.where((key) {
      final item = markedUserDanmakuBox.get(key);
      return item != null &&
          item.siteId == siteId &&
          item.userId == userId;
    }).toList();
    await markedUserDanmakuBox.deleteAll(keys);
  }

  Future clearAllMarkedUserDanmaku() async {
    await markedUserDanmakuBox.clear();
  }

  Future trimDanmakuForUser(String siteId, String userId, int maxCount) async {
    final list = getDanmakuByUser(siteId, userId);
    if (list.length <= maxCount) return;
    final toRemove = list.skip(maxCount).map((e) => e.id).toList();
    await markedUserDanmakuBox.deleteAll(toRemove);
  }

  Future trimDanmakuTotal(int maxCount) async {
    final list = markedUserDanmakuBox.values.toList();
    if (list.length <= maxCount) return;
    list.sort((a, b) => b.sentAt.compareTo(a.sentAt));
    final toRemove = list.skip(maxCount).map((e) => e.id).toList();
    await markedUserDanmakuBox.deleteAll(toRemove);
  }
}
