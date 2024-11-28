

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/detail_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class DetailDownloadButton extends StatefulWidget {
   const DetailDownloadButton({
    super.key,
    this.tag,
  });

  final String? tag;

  @override
  State<DetailDownloadButton> createState() => _DetailDownloadButtonState();
}

class _DetailDownloadButtonState extends State<DetailDownloadButton> {
  late DetailPageController c = Get.find<DetailPageController>(tag: widget.tag);
  
  Widget _buildAndroid(BuildContext context) {
    return Obx(() {
      final isDownloadSelectorState = c.isDownloadSelectorState.value;
      if (!isDownloadSelectorState) {
        return TextButton(
          onPressed: () {
            c.changeDownloadSelectorState();
          },
          child: Row(
            children: [
              const Icon(fluent.FluentIcons.download),
              const SizedBox(width: 10),
              Text('detail.download'.i18n),
            ],
          ),
        );
      } else {
        return TextButton(
          onPressed: () {
            c.changeDownloadSelectorState();
          },
          child: Row(
            children: [
              const Icon(fluent.FluentIcons.check_mark),
              const SizedBox(width: 10),
              Text('detail.confirm'.i18n),
            ],
          ),
        );
      }
    });
    
  }

  Widget _buildDesktop(BuildContext context) {
    return Obx(() {
      final isDownloadSelectorState = c.isDownloadSelectorState.value;
      if (!isDownloadSelectorState) {
        return fluent.FilledButton(
          onPressed: () {
            c.changeDownloadSelectorState();
          },
          child: Row(
            children: [
              const Icon(fluent.FluentIcons.download),
              const SizedBox(width: 10),
              Text('detail.download'.i18n),
            ],
          ),
        );
      } else {
        return fluent.FilledButton(
          onPressed: () {
            c.changeDownloadSelectorState();
          },
          child: Row(
            children: [
              const Icon(fluent.FluentIcons.check_mark),
              const SizedBox(width: 10),
              Text('detail.confirm'.i18n),
            ],
          ),
        );
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}