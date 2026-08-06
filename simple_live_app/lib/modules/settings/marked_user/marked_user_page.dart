import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/models/db/marked_user.dart';
import 'package:simple_live_app/modules/settings/marked_user/marked_user_controller.dart';
import 'package:simple_live_app/modules/settings/marked_user/marked_user_history_page.dart';
import 'package:simple_live_app/services/marked_user_service.dart';

class MarkedUserPage extends GetView<MarkedUserController> {
  const MarkedUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("特别关注"),
        actions: [
          IconButton(
            tooltip: "清空全部弹幕记录",
            onPressed: controller.clearAllHistory,
            icon: const Icon(Remix.delete_bin_line),
          ),
        ],
      ),
      body: Obx(() {
        final users = controller.users;
        if (users.isEmpty) {
          return Center(
            child: Padding(
              padding: AppStyle.edgeInsetsA24,
              child: Text(
                "暂无标记用户\n\n在直播间聊天列表中点击弹幕用户名即可添加",
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: AppStyle.edgeInsetsA12,
          itemCount: users.length,
          separatorBuilder: (_, __) => AppStyle.vGap8,
          itemBuilder: (_, i) {
            final user = users[i];
            return _buildUserCard(user);
          },
        );
      }),
    );
  }

  Widget _buildUserCard(MarkedUser user) {
    final siteName = Sites.allSites[user.siteId]?.name ?? user.siteId;
    final scopeText = user.isGlobal
        ? "全局所有直播间"
        : "仅直播间 ${user.roomId}";
    final historyCount =
        MarkedUserService.instance.getDanmakuByUser(user.siteId, user.userId).length;

    return Card(
      child: Padding(
        padding: AppStyle.edgeInsetsA12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppStyle.vGap4,
                      Text(
                        "$siteName · ID: ${user.userId}",
                        style: Get.textTheme.bodySmall,
                      ),
                      Text(
                        scopeText,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: "删除标记",
                  onPressed: () => controller.removeUser(user),
                  icon: const Icon(Remix.close_circle_line, color: Colors.red),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text("高亮弹幕"),
              value: user.highlight,
              onChanged: (_) => controller.toggleHighlight(user),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text("记录弹幕"),
              value: user.record,
              onChanged: (_) => controller.toggleRecord(user),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    Get.to(() => MarkedUserHistoryPage(user: user));
                  },
                  icon: const Icon(Remix.chat_history_line),
                  label: Text("查看记录 ($historyCount)"),
                ),
                TextButton(
                  onPressed: () => controller.clearUserHistory(user),
                  child: const Text("清空该用户记录"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
