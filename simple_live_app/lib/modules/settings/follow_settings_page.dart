import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/services/follow_service.dart';
import 'package:simple_live_app/widgets/settings/settings_action.dart';
import 'package:simple_live_app/widgets/settings/settings_card.dart';
import 'package:simple_live_app/widgets/settings/settings_switch.dart';
import 'package:simple_live_app/widgets/settings/settings_menu.dart';

class FollowSettingsPage extends GetView<AppSettingsController> {
  const FollowSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("关注设置"),
      ),
      body: ListView(
        padding: AppStyle.pagePadding(),
        children: [
          SettingsCard(
            child: Column(
              children: [
                Obx(
                  () => SettingsMenu<String>(
                    title: "关注刷新模式",
                    value: controller.followRefreshMode.value,
                    valueMap: const {
                      AppSettingsController.kFollowRefreshModeEnhanced:
                          "增强（稳妥/防风控）",
                      AppSettingsController.kFollowRefreshModeLegacy:
                          "快速（旧版逻辑）",
                    },
                    onChanged: (value) {
                      controller.setFollowRefreshMode(value);
                    },
                  ),
                ),
                Padding(
                  padding: AppStyle.edgeInsetsH16.copyWith(bottom: 8, top: 4),
                  child: Obx(
                    () => Text(
                      controller.isLegacyFollowRefresh
                          ? "快速模式：高并发、无抖音限速、不做完整封面补齐流水线，速度接近旧版 1.11.x；抖音关注过多时可能触发平台限制。"
                          : "增强模式：并发更保守、抖音单独限速、手动刷新会补齐封面/标题，更稳但更慢。",
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                AppStyle.divider,
                Obx(
                  () => SettingsSwitch(
                    value: controller.autoUpdateFollowEnable.value,
                    title: "自动更新关注直播状态",
                    onChanged: (e) {
                      controller.setAutoUpdateFollowEnable(e);
                      FollowService.instance.initTimer();
                    },
                  ),
                ),
                Obx(
                  () => Visibility(
                    visible: controller.autoUpdateFollowEnable.value,
                    child: AppStyle.divider,
                  ),
                ),
                Obx(
                  () => Visibility(
                    visible: controller.autoUpdateFollowEnable.value,
                    child: SettingsAction(
                      title: "自动更新间隔",
                      value:
                          "${controller.autoUpdateFollowDuration.value ~/ 60}小时${controller.autoUpdateFollowDuration.value % 60}分钟",
                      onTap: () {
                        setTimer(context);
                      },
                    ),
                  ),
                ),
                AppStyle.divider,
                Obx(
                  () => SettingsMenu<int>(
                    title: "更新线程数",
                    value: controller.effectiveUpdateFollowThreadCount,
                    valueMap: const {
                      0: "自动",
                      1: "1",
                      2: "2",
                      3: "3",
                      4: "4",
                      5: "5",
                      6: "6",
                      7: "7",
                      8: "8",
                    },
                    onChanged: (value) {
                      controller.setUpdateFollowThreadCount(value);
                    },
                  ),
                ),
                Padding(
                  padding: AppStyle.edgeInsetsH16.copyWith(bottom: 8, top: 4),
                  child: Obx(
                    () => Text(
                      controller.isLegacyFollowRefresh
                          ? "快速模式「自动」会按 CPU 估算并发（约 4～20）；手动 1～8 可再调。"
                          : "增强模式「自动」并发最高约 4；手动 1～8 可再调。",
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                AppStyle.divider,
                Obx(
                  () => SettingsMenu<int>(
                    title: "关注每页数量",
                    value: controller.followPageSize.value,
                    valueMap: const {
                      50: "50",
                      100: "100",
                      150: "150",
                      200: "200",
                      300: "300",
                      400: "400",
                    },
                    onChanged: (value) {
                      controller.setFollowPageSize(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void setTimer(BuildContext context) async {
    var value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: controller.autoUpdateFollowDuration.value ~/ 60,
        minute: controller.autoUpdateFollowDuration.value % 60,
      ),
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (_, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );
    if (value == null || (value.hour == 0 && value.minute == 0)) {
      return;
    }
    var duration = Duration(hours: value.hour, minutes: value.minute);
    controller.setAutoUpdateFollowDuration(duration.inMinutes);
    FollowService.instance.initTimer();
  }
}
