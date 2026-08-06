import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/controller/base_controller.dart';
import 'package:simple_live_app/app/utils.dart';
import 'package:simple_live_app/models/db/marked_user.dart';
import 'package:simple_live_app/models/db/marked_user_danmaku.dart';
import 'package:simple_live_app/services/marked_user_service.dart';

class MarkedUserController extends BaseController {
  final MarkedUserService service = MarkedUserService.instance;

  List<MarkedUser> get users => service.markedUsers;

  Future<void> refreshList() async {
    await service.reload();
  }

  Future<void> toggleHighlight(MarkedUser user) async {
    await service.setHighlight(user.id, !user.highlight);
  }

  Future<void> toggleRecord(MarkedUser user) async {
    await service.setRecord(user.id, !user.record);
  }

  Future<void> removeUser(MarkedUser user) async {
    final ok = await Utils.showAlertDialog(
      "确定取消对「${user.userName}」的标记吗？\n已记录的弹幕会保留，可在「查看记录」中手动清空。",
      title: "取消标记",
    );
    if (!ok) return;
    await service.removeMarkedUser(user.id, deleteHistory: false);
    SmartDialog.showToast("已取消标记");
  }

  List<MarkedUserDanmaku> getDanmaku(MarkedUser user) {
    return service.getDanmakuByUser(user.siteId, user.userId);
  }

  Future<void> clearUserHistory(MarkedUser user) async {
    final ok = await Utils.showAlertDialog(
      "确定清空「${user.userName}」的全部已记录弹幕吗？",
      title: "清空记录",
    );
    if (!ok) return;
    await service.clearDanmakuByUser(user.siteId, user.userId);
    SmartDialog.showToast("已清空");
    update();
  }

  Future<void> clearAllHistory() async {
    final ok = await Utils.showAlertDialog(
      "确定清空全部标记用户的弹幕记录吗？（不会删除标记本身）",
      title: "清空全部记录",
    );
    if (!ok) return;
    await service.clearAllDanmaku();
    SmartDialog.showToast("已清空全部记录");
    update();
  }
}
