import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SliverNavigationBar extends StatefulWidget {
  final ScrollController scrollController;
  final Widget? largeTitle;
  final Widget? leading;
  final bool? alwaysShowMiddle;
  final String? previousPageTitle;
  final Widget? middle;
  final Widget? trailing;
  final Color color;
  final Color darkColor;

  const SliverNavigationBar(
      {super.key,
      required this.scrollController,
      this.largeTitle,
      this.leading,
      this.alwaysShowMiddle = false,
      this.previousPageTitle,
      this.middle,
      this.trailing,
      this.color = Colors.white,
      this.darkColor = Colors.black});

  @override
  State<SliverNavigationBar> createState() => _NavState();
}

class _NavState extends State<SliverNavigationBar> {
  final _threshold = 52;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      if (widget.scrollController.offset >= _threshold && !_isCollapsed) {
        setState(() {
          _isCollapsed = true;
        });
      } else if (widget.scrollController.offset < _threshold && _isCollapsed) {
        setState(() {
          _isCollapsed = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.maybeBrightnessOf(context) == Brightness.dark;

    return CupertinoSliverNavigationBar(
      largeTitle: widget.largeTitle,
      leading: widget.leading,
      trailing: widget.trailing,
      alwaysShowMiddle: widget.alwaysShowMiddle ?? false,
      previousPageTitle: widget.previousPageTitle,
      middle: widget.middle,
      stretch: true,
      backgroundColor: _isCollapsed
          ? isDark
              ? const Color.fromRGBO(45, 45, 45, 0.5)
              : Colors.white.withOpacity(0.5)
          : const SpecialColor(),
      border: Border(
        bottom: BorderSide(
          color: _isCollapsed
              ? isDark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.black.withOpacity(0.5)
              : const SpecialColor(),
          width: 0.0, // 0.0 means one physical pixel
        ),
      ),
    );
  }
}

// SpecialColor to remove CupertinoSliverNavigationBar blur effect
class SpecialColor extends Color {
  const SpecialColor() : super(0x00000000);

  @override
  int get alpha => 0xFF;
}
