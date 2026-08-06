import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/models/db/marked_user.dart';
import 'package:simple_live_app/models/db/marked_user_danmaku.dart';
import 'package:simple_live_app/services/marked_user_service.dart';

class MarkedUserHistoryPage extends StatelessWidget {
  final MarkedUser user;
  const MarkedUserHistoryPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final siteName = Sites.allSites[user.siteId]?.name ?? user.siteId;
    final list = MarkedUserService.instance
        .getDanmakuByUser(user.siteId, user.userId);

    return Scaffold(
      appBar: AppBar(
        title: Text("${user.userName} 的弹幕记录"),
      ),
      body: list.isEmpty
          ? Center(
              child: Text(
                "暂无记录\n开启「记录弹幕」后，该用户新发弹幕会保存在此",
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: AppStyle.edgeInsetsA12,
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final item = list[i];
                return _buildItem(item, siteName);
              },
            ),
    );
  }

  Widget _buildItem(MarkedUserDanmaku item, String siteName) {
    final time =
        "${item.sentAt.year.toString().padLeft(4, '0')}-${item.sentAt.month.toString().padLeft(2, '0')}-${item.sentAt.day.toString().padLeft(2, '0')} "
        "${item.sentAt.hour.toString().padLeft(2, '0')}:${item.sentAt.minute.toString().padLeft(2, '0')}:${item.sentAt.second.toString().padLeft(2, '0')}";

    return ListTile(
      contentPadding: AppStyle.edgeInsetsV8,
      title: Text(item.content),
      subtitle: Text(
        [
          time,
          if (item.roomTitle.isNotEmpty) item.roomTitle,
          "房间 ${item.roomId}",
          siteName,
        ].join(" · "),
        style: Get.textTheme.bodySmall,
      ),
    );
  }
}
