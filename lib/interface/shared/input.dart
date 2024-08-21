// ignore_for_file: prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oshi/share/share.dart';

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
