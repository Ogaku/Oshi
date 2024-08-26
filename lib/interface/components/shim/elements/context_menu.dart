// ignore_for_file: non_constant_identifier_names
import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/share/share.dart';

Widget AdaptiveContextMenu({required List<AdaptiveContextMenuAction> actions, required Widget child}) =>
    Share.settings.appSettings.useCupertino
        ? CupertinoContextMenu.builder(
            enableHapticFeedback: true,
            actions: actions
                .select((x, _) => CupertinoContextMenuAction(
                      onPressed: x.onPressed,
                      trailingIcon: x.icon,
                      isDestructiveAction: x.isDestructiveAction,
                      child: Text(x.title),
                    ))
                .toList(),
            builder: (_, animation) => ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                    maxWidth: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 250),
                child: child))
        : AdaptiveMenuButton(
            itemBuilder: (context) => actions
                .select((x, _) => AdaptiveMenuItem(
                      icon: x.icon,
                      title: x.title,
                      onTap: x.onPressed,
                      isDestructive: x.isDestructiveAction,
                    ))
                .toList(),
            longPressOnly: true,
            child: child);

class AdaptiveContextMenuAction extends StatelessWidget {
  const AdaptiveContextMenuAction({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.isDestructiveAction = false,
  });

  final String title;
  final IconData icon;
  final bool isDestructiveAction;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Share.settings.appSettings.useCupertino
        ? CupertinoContextMenuAction(
            onPressed: onPressed,
            trailingIcon: icon,
            isDestructiveAction: isDestructiveAction,
            child: Text(title),
          )
        : AdaptiveMenuItem(
            icon: icon,
            title: title,
            onTap: onPressed,
            isDestructive: isDestructiveAction,
          );
  }
}
