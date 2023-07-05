import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/widgets/cache_network_image.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress_ring.dart';

class ExtensionCard extends StatefulWidget {
  const ExtensionCard({
    Key? key,
    required this.name,
    required this.version,
    required this.icon,
    required this.package,
  }) : super(key: key);
  final String icon;
  final String name;
  final String version;
  final String package;

  @override
  State<ExtensionCard> createState() => _ExtensionCardState();
}

class _ExtensionCardState extends State<ExtensionCard> {
  bool isLoading = false;
  bool isInstall = false;
  bool hasUpdate = false;

  @override
  void initState() {
    setState(() {
      isInstall = ExtensionUtils.extensions.containsKey(widget.package);
      hasUpdate = isInstall &&
          ExtensionUtils.extensions[widget.package]!.extension.version !=
              widget.version;
    });
    super.initState();
  }

  _install() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = MiruStorage.getSetting(SettingKey.miruRepoUrl) +
          "/repo/${widget.package}.js";
      debugPrint(url);
      await ExtensionUtils.install(url, context);
      isLoading = false;
      isInstall = true;
    } catch (e) {
      debugPrint(e.toString());
      isLoading = false;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildAndroid(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 35,
        height: 35,
        child: CacheNetWorkImage(
          widget.icon,
          fit: BoxFit.contain,
          fallback: const Icon(Icons.extension),
        ),
      ),
      title: Text(widget.name),
      subtitle: Text(
        widget.version,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isInstall && hasUpdate)
            isLoading
                ? const SizedBox(
                    width: 25,
                    height: 25,
                    child: fluent.ProgressRing(),
                  )
                : FilledButton(
                    child: const Text("更新"),
                    onPressed: () async {
                      await _install();
                      setState(() {});
                    }),
          const SizedBox(width: 8),
          if (isInstall)
            TextButton(
              child: const Text("卸载"),
              onPressed: () async {
                await ExtensionUtils.uninstall(widget.package);
                setState(() {
                  isInstall = false;
                });
              },
            )
          else
            isLoading
                ? const SizedBox(
                    width: 25,
                    height: 25,
                    child: ProgressRing(),
                  )
                : TextButton(
                    onPressed: () async {
                      await _install();
                    },
                    child: const Text("安装"),
                  )
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            SizedBox(
              height: 120,
              child: CacheNetWorkImage(
                widget.icon,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const Positioned.fill(child: fluent.Acrylic()),
            Positioned.fill(
              child: Center(
                  child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CacheNetWorkImage(
                  widget.icon,
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                  fallback: const Icon(fluent.FluentIcons.add_in, size: 32),
                ),
              )),
            ),
          ],
        ),
        Expanded(
            child: Container(
          color: fluent.FluentTheme.of(context).cardColor,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.name, style: const TextStyle(fontSize: 17)),
              const Spacer(),
              Row(
                children: [
                  Text(widget.version, style: const TextStyle(fontSize: 12)),
                  const Spacer(),
                  if (isInstall && hasUpdate)
                    isLoading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: fluent.ProgressRing(),
                          )
                        : fluent.FilledButton(
                            child: const Text("更新"),
                            onPressed: () async {
                              await _install();
                              setState(() {});
                            }),
                  const SizedBox(width: 8),
                  if (isInstall)
                    fluent.FilledButton(
                      child: const Text("卸载"),
                      onPressed: () async {
                        await ExtensionUtils.uninstall(widget.package);
                        setState(() {
                          isInstall = false;
                        });
                      },
                    )
                  else
                    isLoading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: ProgressRing(),
                          )
                        : fluent.FilledButton(
                            onPressed: () async {
                              await _install();
                            },
                            child: const Text("安装"),
                          )
                ],
              ),
            ],
          ),
        ))
      ],
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