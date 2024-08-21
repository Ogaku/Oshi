import 'package:flutter/cupertino.dart';

class TextChip extends StatefulWidget {
  final String text;
  final double? width;
  final EdgeInsets? insets;
  final EdgeInsets? margin;
  final void Function()? tapped;
  final double? radius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool noMargin;

  const TextChip(
      {super.key,
      required this.text,
      this.tapped,
      this.insets,
      this.margin,
      this.width,
      this.radius,
      this.fontSize,
      this.fontWeight,
      this.noMargin = false});

  @override
  State<TextChip> createState() => _NavState();
}

class _NavState extends State<TextChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: widget.insets ?? const EdgeInsets.only(left: 10, top: 4, right: 10, bottom: 5),
      margin: widget.margin ?? const EdgeInsets.all(0),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(widget.radius ?? 5)), color: const Color(0x33AAAAAA)),
      child: Container(
          padding: EdgeInsets.only(top: 3, bottom: widget.noMargin ? 3 : 0),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: CupertinoTheme.of(context).primaryColor,
                fontSize: widget.fontSize ?? 17,
                fontWeight: widget.fontWeight ?? FontWeight.w400),
          )),
    );
  }
}
