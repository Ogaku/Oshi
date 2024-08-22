// ignore_for_file: prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oshi/share/share.dart';
import 'package:pull_down_button/pull_down_button.dart';

class AdaptiveTextField extends StatefulWidget {
  const AdaptiveTextField({
    super.key,
    required this.controller,
    this.placeholder = '',
    this.enabled = true,
    this.setState,
    this.secondary = false,
  });

  final TextEditingController controller;
  final String placeholder;
  final bool enabled;
  final bool secondary;
  final void Function(void Function())? setState;

  @override
  State<AdaptiveTextField> createState() => _AdaptiveTextFieldState();
}

class _AdaptiveTextFieldState extends State<AdaptiveTextField> {
  @override
  Widget build(BuildContext context) {
    if (Share.settings.appSettings.useCupertino) {
      return CupertinoTextField.borderless(
          maxLines: null,
          enabled: widget.enabled,
          onChanged: (s) {
            setState(() {});
            widget.setState?.call(() {});
          },
          controller: widget.controller,
          placeholder: widget.placeholder,
          placeholderStyle: TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.tertiaryLabel));
    } else {
      return Container(
        margin: EdgeInsets.only(left: 5),
        child: TextFormField(
          maxLines: null,
          enabled: widget.enabled,
          onChanged: (s) {
            setState(() {});
            widget.setState?.call(() {});
          },
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: widget.secondary ? TextStyle(fontWeight: FontWeight.w400, color: Colors.grey) : null,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintTextDirection: TextDirection.ltr,
            fillColor: Colors.transparent,
          ),
        ),
      );
    }
  }
}

class AdaptiveMenuButton extends StatefulWidget {
  AdaptiveMenuButton({
    super.key,
    required this.itemBuilder,
    Widget? child,
  }) : child = child ?? Icon(Share.settings.appSettings.useCupertino ? CupertinoIcons.ellipsis_circle : Icons.more_vert);

  final Widget child;
  final PullDownMenuItemBuilder itemBuilder;

  @override
  State<AdaptiveMenuButton> createState() => _AdaptiveMenuButtonState();
}

class _AdaptiveMenuButtonState extends State<AdaptiveMenuButton> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final MenuController _menuController = MenuController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          _menuController.close();
        } else if (!_menuController.isOpen) {
          _menuController.open();
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Share.settings.appSettings.useCupertino
      ? PullDownButton(
          itemBuilder: widget.itemBuilder,
          buttonBuilder: (_, showMenu) => GestureDetector(
            onTap: showMenu,
            child: widget.child,
          ),
        )
      : MenuAnchor(
          controller: _menuController,
          onClose: _animationController.reset,
          onOpen: _animationController.forward,
          builder: (_, controller, child) => IconButton(
            onPressed: () {
              if (_animationController.status case AnimationStatus.forward || AnimationStatus.completed) {
                _animationController.reverse();
              } else {
                _animationController.forward();
              }
            },
            icon: widget.child,
          ),
          menuChildren: [
            FadeTransition(
                opacity: _animationController,
                child: Column(
                    children: widget
                        .itemBuilder(context)
                        .where((x) => x is AdaptiveMenuItem || Share.settings.appSettings.useCupertino)
                        .toList()))
          ],
        );
}

class AdaptiveMenuItem extends StatelessWidget implements PullDownMenuEntry {
  const AdaptiveMenuItem({
    super.key,
    required this.onTap,
    this.enabled = true,
    required this.title,
    this.subtitle,
    this.icon,
    this.isDestructive = false,
  });

  final VoidCallback? onTap;
  final bool enabled;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) => Share.settings.appSettings.useCupertino
      ? PullDownMenuItem(
          onTap: onTap,
          enabled: enabled,
          title: title,
          subtitle: subtitle,
          icon: icon ?? CupertinoIcons.circle,
          isDestructive: isDestructive,
        )
      : MenuItemButton(
          onPressed: onTap,
          leadingIcon: Icon(icon, size: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDestructive ? Theme.of(context).colorScheme.error : null,
                  ),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
            ],
          ),
        );
}
