import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  final bool? transitionBetweenRoutes;
  final double threshold;
  final bool alternativeVisibility;
  final Color? backgroundColor;

  const SliverNavigationBar(
      {super.key,
      required this.scrollController,
      this.transitionBetweenRoutes,
      this.largeTitle,
      this.leading,
      this.alwaysShowMiddle = false,
      this.previousPageTitle,
      this.middle,
      this.trailing,
      this.threshold = 52,
      this.alternativeVisibility = false,
      this.color = Colors.white,
      this.darkColor = Colors.black,
      this.backgroundColor});

  @override
  State<SliverNavigationBar> createState() => _NavState();
}

class _NavState extends State<SliverNavigationBar> {
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    if (widget.middle != null && widget.alternativeVisibility) {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
      return;
    }

    widget.scrollController.addListener(() {
      if (widget.scrollController.offset >= widget.threshold && !_isCollapsed) {
        setState(() {
          _isCollapsed = true;
        });
      } else if (widget.scrollController.offset < widget.threshold && _isCollapsed) {
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
      backgroundColor: widget.backgroundColor ??
          (_isCollapsed
              ? isDark
                  ? const Color.fromRGBO(45, 45, 45, 0.5)
                  : Colors.white.withOpacity(0.5)
              : const CupertinoDynamicColor.withBrightness(
                  color: Color.fromARGB(255, 242, 242, 247), darkColor: Color.fromARGB(255, 0, 0, 0))),
      transitionBetweenRoutes: widget.transitionBetweenRoutes ?? true,
      largeTitle: widget.largeTitle,
      leading: widget.leading,
      trailing: widget.trailing,
      alwaysShowMiddle: widget.alwaysShowMiddle ?? false,
      previousPageTitle: widget.previousPageTitle,
      middle: (widget.middle != null && widget.alternativeVisibility)
          ? VisibilityDetector(
              key: UniqueKey(),
              onVisibilityChanged: (VisibilityInfo info) => setState(() => _isCollapsed = info.visibleFraction >= 1.0),
              child: widget.middle!)
          : widget.middle,
      stretch: true,
      border: Border(
        bottom: BorderSide(
          color: _isCollapsed ? const Color(0x4D000000) : const Color(0x00000000),
          width: 0.0,
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
