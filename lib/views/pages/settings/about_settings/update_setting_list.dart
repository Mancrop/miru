import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/settings/android_setting_list.dart';
import 'package:miru_app/views/widgets/settings/settings_tile.dart';
import 'package:miru_app/views/widgets/settings/settings_switch_tile.dart';

class UpdateSettingList extends StatefulWidget {
  const UpdateSettingList({super.key});

  @override
  State<UpdateSettingList> createState() => _UpdateSettingListState();
}

class _UpdateSettingListState extends State<UpdateSettingList> {
  bool _autoCheckForUpdates = true;
  final String _updateChannel = "Development Builds";
  final String _distributionPlatform = "GitHub";
  final String _githubProxy = "https://gh-proxy.com/";
  String _lastCheckResult = "";

  @override
  Widget build(BuildContext context) {
    return AndroidSettingList(
      icon: const Icon(Icons.update),
      mainTitle: "Updates",
      children: [
        // Auto Check for Updates
        SettingsSwitchTile(
          icon: const Icon(Icons.download),
          title: "Auto Check for Updates",
          buildSubtitle: () => "Enable automatic update checks upon app launch",
          buildValue: () => _autoCheckForUpdates,
          onChanged: (value) {
            setState(() {
              _autoCheckForUpdates = value;
            });
          },
          isCard: false,
        ),
        
        // Update Channel
        SettingsTile(
          icon: const Icon(Icons.alt_route),
          title: "Update Channel",
          buildSubtitle: () => "Select your preferred update channel.",
          trailing: Text(
            _updateChannel,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onTap: () {
            // Show channel selection dialog
          },
        ),
        
        // Distribution Platform
        SettingsTile(
          icon: const Icon(Icons.history),
          title: "Distribution Platform",
          trailing: Text(
            _distributionPlatform,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onTap: () {
            // Show platform selection dialog
          },
        ),
        
        // GitHub Proxy
        SettingsTile(
          icon: const Icon(Icons.security),
          title: "GitHub Proxy",
          buildSubtitle: () => "Choose a GitHub proxy for faster access, if applicable",
          trailing: Text(
            _githubProxy,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onTap: () {
            // Show GitHub proxy dialog
          },
        ),
        
        // Check for Updates
        SettingsTile(
          icon: const Icon(Icons.update),
          title: "Check for Updates",
          buildSubtitle: () => _lastCheckResult.isEmpty 
            ? "Check and install the latest version."
            : _lastCheckResult,
          onTap: () {
            setState(() {
              _lastCheckResult = "20:37 | 失败: a HTTP error fetching URL. Status=410, URL=[https://api.appcenter.ms/v0.1/public...]";
            });
            // Implement update check logic
          },
        ),
      ],
    );
  }
}
