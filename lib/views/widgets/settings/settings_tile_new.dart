import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class SettingsTile extends StatefulWidget {
  const SettingsTile({
    super.key,
    this.icon,
    required this.title,
    this.trailing,
    this.buildSubtitle,
    this.onTap,
    this.isCard = false,
    this.radius = const BorderRadius.all(Radius.circular(16.0)),
  });
  final Widget? icon;
  final String title;
  final String Function()? buildSubtitle;
  final Function()? onTap;
  final Widget? trailing;
  final bool isCard;
  final BorderRadius radius;

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
  Widget _buildAndroid(BuildContext context) {
    final content = Row(
      children: [
        if (widget.icon != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              child: widget.icon!,
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              if (widget.buildSubtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.buildSubtitle!.call(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.trailing != null) widget.trailing!,
      ],
    );

    // 不再使用原来的卡片样式，直接返回带有内边距的按钮
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: widget.radius,
        ),
        alignment: Alignment.centerLeft,
      ),
      onPressed: widget.onTap,
      child: content,
    );
  }

  Widget _buildDesktop(BuildContext context) {
    Widget content = Row(
      children: [
        if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 16),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.title),
            if (widget.buildSubtitle != null)
              Text(
                widget.buildSubtitle!.call(),
                style: const TextStyle(fontSize: 14),
              )
          ],
        ),
        const Spacer(),
        widget.trailing ?? const SizedBox(),
      ],
    );

    if (widget.onTap != null) {
      content = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }

    if (widget.isCard) {
      return fluent.Card(
        child: content,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
