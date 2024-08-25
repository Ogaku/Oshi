// ignore_for_file: prefer_const_constructors
import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oshi/interface/components/cupertino/widgets/options_form.dart';
import 'package:oshi/interface/shared/containers.dart';
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
    this.maxLines,
  });

  final TextEditingController controller;
  final String placeholder;
  final bool enabled;
  final bool secondary;
  final int? maxLines;
  final void Function(void Function())? setState;

  @override
  State<AdaptiveTextField> createState() => _AdaptiveTextFieldState();
}

class _AdaptiveTextFieldState extends State<AdaptiveTextField> {
  @override
  Widget build(BuildContext context) {
    if (Share.settings.appSettings.useCupertino) {
      return CupertinoTextField.borderless(
          maxLines: widget.maxLines,
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
          maxLines: widget.maxLines,
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

void showOptionDialog<T>(
        {required BuildContext context,
        required String title,
        IconData? icon,
        required T selection,
        required List<OptionEntry<T>> options,
        required void Function(T) onChanged}) =>
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dynamic group = selection;
        return Dialog(child: StatefulBuilder(builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Icon(icon, size: 25),
                ),
              Padding(
                padding: EdgeInsets.only(top: (icon != null) ? 20 : 30, bottom: 20.0),
                child: Text(title, style: TextStyle(fontSize: 27)),
              ),
            ]
                .appendAll(options.select((x, _) => Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: ListTile(
                        onTap: () => setState(() => group = x.value),
                        contentPadding: EdgeInsets.only(left: 16.0, right: 5.0),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                        title: Table(
                            columnWidths:
                                x.decoration != null ? const {0: FlexColumnWidth(2), 1: IntrinsicColumnWidth()} : null,
                            children: [
                              TableRow(children: [
                                Text(x.name, style: TextStyle(fontSize: 17), overflow: TextOverflow.ellipsis),
                                if (x.decoration != null) x.decoration!
                              ])
                            ]),
                        trailing: Radio(
                          value: x.value,
                          groupValue: group,
                          onChanged: (value) => setState(() => group = value),
                        )))))
                .append(Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 26.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                      onPressed: () {
                        onChanged(group); // Handle change
                        Navigator.of(context).pop();
                      },
                      child: Text('Apply', style: TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.onPrimary)),
                    ),
                  ),
                ))
                .toList(),
          );
        }));
      },
    );

typedef Callback<T> = void Function(T value);

class AdaptiveFormRow<T> extends StatelessWidget {
  AdaptiveFormRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.maxLength,
    this.helper,
    this.noMargin = false,
  });

  final String title; // Title of the form row
  final T value; // Initial and updated value
  final dynamic Function(T) onChanged; // With validation
  final bool noMargin; // No margin

  final T? placeholder; // For string-based values
  final int? maxLength; // For string-based values
  final String? helper; // Helper text

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (value is String) _controller.text = value as String;
    return StatefulBuilder(builder: (context, setState) {
      if (Share.settings.appSettings.useCupertino) {
        return switch (value.runtimeType) {
          // Switch for boolean variables
          bool => CupertinoFormRow(
              prefix: Flexible(flex: 3, child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
              child: CupertinoSwitch(value: value as bool, onChanged: (s) => setState(() => onChanged(s as T)))),
          // Input field for string-based values
          String => CupertinoListTile(
                title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 100),
                    child: CupertinoTextField.borderless(
                        onChanged: (s) => setState(() {}),
                        onSubmitted: (value) {
                          var result = onChanged(value as T);
                          setState(() => _controller.text = result);
                        },
                        controller: _controller,
                        placeholder: placeholder as String?,
                        expands: false,
                        textAlign: TextAlign.end,
                        maxLength: maxLength ?? 10,
                        showCursor: _controller.text.isNotEmpty,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced)),
              ],
            )),
          // Everything else
          _ => Text('Unsupported type: ${T.runtimeType}')
        };
      } else {
        return switch (value.runtimeType) {
          // Switch for boolean variables
          bool => AdaptiveCard(
              child: title,
              after: helper,
              regular: true,
              margin: noMargin ? EdgeInsets.symmetric(horizontal: 6) : null,
              trailingElement: Switch(value: value as bool, onChanged: (s) => setState(() => onChanged(s as T))),
            ),
          // Input field for string-based values
          String => AdaptiveCard(
              child: title,
              after: helper,
              regular: true,
              margin: noMargin ? EdgeInsets.symmetric(horizontal: 6) : null,
              trailingElement: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 100),
                child: TextFormField(
                  onChanged: (s) => setState(() {}),
                  onFieldSubmitted: (value) {
                    var result = onChanged(value as T);
                    setState(() => _controller.text = result);
                  },
                  controller: _controller,
                  expands: false,
                  textAlign: TextAlign.end,
                  maxLength: maxLength ?? 10,
                  showCursor: _controller.text.isNotEmpty,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: InputDecoration(
                    hintText: placeholder as String?,
                    counterText: "",
                    hintStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintTextDirection: TextDirection.ltr,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          // Everything else
          _ => Text('Unsupported type: ${T.runtimeType}')
        };
      }
    });
  }
}

class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    super.key,
    required this.title,
    required this.click,
  });

  final String title;
  final void Function()? click;

  @override
  Widget build(BuildContext context) => Share.settings.appSettings.useCupertino
      ? CupertinoButton(
          padding: EdgeInsets.all(0),
          onPressed: click,
          child: Text(title, style: TextStyle(color: CupertinoTheme.of(context).primaryColor)))
      : TextButton(onPressed: click, child: Text(title, style: TextStyle(fontSize: 17)));
}
