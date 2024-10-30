import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/layout.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/watch/control_panel_footer.dart';
import 'package:miru_app/views/widgets/watch/control_panel_header.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';

class ReaderView<T extends ReaderController> extends StatelessWidget {
  const ReaderView(
    this.tag, {
    super.key,
    required this.content,
    required this.buildSettings,
  });
  final String tag;
  final Widget content;
  final Widget Function(BuildContext context) buildSettings;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<T>(tag: tag);
    return Obx(
      () => Stack(
        children: [
          MouseRegion(
            onHover: (event) {
              if (event.position.dy < 60) {
                c.showControlPanel();
              }
              if (event.position.dy > LayoutUtils.height - 60) {
                c.showControlPanel();
              }
            },
            child: content,
          ),

          // 点击中间显示控制面板
          // 左边上一页右边下一页
          if (c.error.value.isEmpty)
            Positioned(
              top: 120,
              bottom: 120,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTapDown: (TapDownDetails details) {
                  final xPos = details.globalPosition.dx;
                  final width = LayoutUtils.width;
                  final unitWidth = width / 3;
                  if (xPos < unitWidth) {
                    return c.previousPage();
                  }
                  if (xPos > unitWidth * 2) {
                    return c.nextPage();
                  }
                  c.isShowControlPanel.value = !c.isShowControlPanel.value;
                },
              ),
            ),

          if (c.isShowControlPanel.value) ...[
            // 顶部控制
            Positioned(
              child: ControlPanelHeader<T>(
                tag,
                buildSettings: buildSettings,
              ),
            ),
            // 中间控制
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: PlatformFilledButton(
                  child: Text('common.download'.i18n),
                  onPressed: () {
                    c.download();
                  },
                ),
              ),
            ),
            // 底部控制
            Positioned(
              right: 0,
              left: 0,
              bottom: 25,
              child: ControlPanelFooter<T>(tag),
            ),
          ]
        ],
      ),
    );
  }
}
