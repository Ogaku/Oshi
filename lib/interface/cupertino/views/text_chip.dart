import 'package:flutter/cupertino.dart';

class TextChip extends StatefulWidget {
  final String text;
  final EdgeInsets? insets;
  final void Function()? tapped;

  const TextChip({super.key, required this.text, this.tapped, this.insets});

  @override
  State<TextChip> createState() => _NavState();
}

class _NavState extends State<TextChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.insets ?? const EdgeInsets.all(5),
      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Color(0x44BBBBBB)),
      child: Text(
        widget.text,
        style: const TextStyle(color: CupertinoColors.systemRed),
      ),
    );
  }
}
