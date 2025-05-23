import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class PlatformButton extends StatelessWidget {
  const PlatformButton({
    super.key,
    required this.child,
    this.onPressed,
  });
  final Widget child;
  final VoidCallback? onPressed;

  Widget _builaAndroidButton(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: child);
  }

  Widget _builaDesktopButton(BuildContext context) {
    return fluent.Button(onPressed: onPressed, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _builaAndroidButton,
      desktopBuilder: _builaDesktopButton,
    );
  }
}

class PlatformFilledButton extends StatelessWidget {
  const PlatformFilledButton({
    super.key,
    required this.child,
    this.onPressed,
  });
  final Widget child;
  final VoidCallback? onPressed;

  Widget _builaAndroidButton(BuildContext context) {
    return FilledButton(onPressed: onPressed, child: child);
  }

  Widget _builaDesktopButton(BuildContext context) {
    return fluent.FilledButton(onPressed: onPressed, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _builaAndroidButton,
      desktopBuilder: _builaDesktopButton,
    );
  }
}

class PlatformTextButton extends StatelessWidget {
  const PlatformTextButton({
    super.key,
    required this.child,
    this.onPressed,
  });
  final Widget child;
  final VoidCallback? onPressed;

  Widget _builaAndroidButton(BuildContext context) {
    return TextButton(onPressed: onPressed, child: child);
  }

  Widget _builaDesktopButton(BuildContext context) {
    return fluent.HyperlinkButton(onPressed: onPressed, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _builaAndroidButton,
      desktopBuilder: _builaDesktopButton,
    );
  }
}

class PlatformIconButton extends StatelessWidget {
  const PlatformIconButton({
    super.key,
    required this.icon,
    this.onPressed,
  });
  final Widget icon;
  final VoidCallback? onPressed;

  Widget _builaAndroidButton(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: icon);
  }

  Widget _builaDesktopButton(BuildContext context) {
    return fluent.IconButton(onPressed: onPressed, icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _builaAndroidButton,
      desktopBuilder: _builaDesktopButton,
    );
  }
}

class PlatformToggleButton extends fluent.StatelessWidget {
  const PlatformToggleButton({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.text,
  });

  final bool checked;
  final void Function(bool)? onChanged;
  final String text;

  Widget _buildAndroid(BuildContext context) {
    return TextButton(
      onPressed: () => onChanged?.call(!checked),
      style: ButtonStyle(
        side: WidgetStateProperty.all(
          BorderSide(
            color: checked
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: checked
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.ToggleButton(
      checked: checked,
      onChanged: onChanged,
      child: Text(text),
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
