import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/settings/android_setting_list.dart';
import 'package:miru_app/views/widgets/settings/settings_switch_tile.dart';

class DisplaySettingList extends StatefulWidget {
  const DisplaySettingList({super.key});

  @override
  State<DisplaySettingList> createState() => _DisplaySettingListState();
}

class _DisplaySettingListState extends State<DisplaySettingList> {
  bool _darkThemeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return AndroidSettingList(
      icon: const Icon(Icons.brightness_medium),
      mainTitle: "Display",
      children: [
        // Dark Theme
        SettingsSwitchTile(
          icon: const Icon(Icons.dark_mode),
          title: "Dark Theme",
          buildSubtitle: () => "Override the app's dark theme setting",
          buildValue: () => _darkThemeEnabled,
          onChanged: (value) {
            setState(() {
              _darkThemeEnabled = value;
            });
          },
          isCard: false,
        ),
      ],
    );
  }
}
