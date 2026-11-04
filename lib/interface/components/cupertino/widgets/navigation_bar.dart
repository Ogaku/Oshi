import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CollapsedController with ChangeNotifier {
  bool _collapsed = false;
  bool _isDark = true;

  bool get collapsed => _collapsed;
  set collapsed(bool value) {
    _collapsed = value;
    notifyListeners();
  }

  bool get isDark => _isDark;
  set isDark(bool value) {
    _isDark = value;
    notifyListeners();
  }
}

class SliverNavigationBar extends StatefulWidget {
  final ScrollController scrollController;
  final CollapsedController? collapsedController;
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
  final bool noBorder;
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
      this.noBorder = false,
      this.trailing,
      this.threshold = 52,
      this.alternativeVisibility = false,
      this.color = Colors.white,
      this.darkColor = Colors.black,
      this.backgroundColor,
      this.collapsedController});

  @override
  State<SliverNavigationBar> createState() => _NavState();
}

class _NavState extends State<SliverNavigationBar> {
  bool _isCollapsed = false;
  bool _isDark = true;

  @override
  void dispose() {
    widget.scrollController.removeListener(scrollListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(scrollListener);
    if (widget.middle != null && widget.alternativeVisibility) {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
      return;
    }
  }

  void scrollListener() {
    if (!mounted) return;
    if (widget.scrollController.offset >= widget.threshold && !_isCollapsed) {
      setState(() {
        _isCollapsed = true;
      });
      widget.collapsedController?.collapsed = _isCollapsed;
      widget.collapsedController?.isDark = _isDark;
    } else if (widget.scrollController.offset < widget.threshold && _isCollapsed) {
      setState(() {
        _isCollapsed = false;
      });
      widget.collapsedController?.collapsed = _isCollapsed;
      widget.collapsedController?.isDark = _isDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    _isDark = CupertinoTheme.maybeBrightnessOf(context) == Brightness.dark;

    return CupertinoSliverNavigationBar(
      backgroundColor: widget.backgroundColor ??
          (_isCollapsed
              ? widget.noBorder
                  ? CupertinoTheme.of(context).barBackgroundColor.withAlpha(255)
                  : _isDark
                      ? const Color.fromRGBO(45, 45, 45, 0.5)
                      : Colors.white.withOpacity(0.5)
              : CupertinoDynamicColor.resolve(
                  const CupertinoDynamicColor.withBrightness(
                      color: Color.fromARGB(255, 242, 242, 247), darkColor: Color.fromARGB(255, 0, 0, 0)),
                  context)),
      transitionBetweenRoutes: widget.transitionBetweenRoutes ?? true,
      largeTitle: widget.largeTitle,
      leading: widget.leading,
      trailing: widget.trailing,
      alwaysShowMiddle: widget.alwaysShowMiddle ?? false,
      previousPageTitle: widget.previousPageTitle,
      middle: (widget.middle != null && widget.alternativeVisibility)
          ? VisibilityDetector(
              key: UniqueKey(),
              onVisibilityChanged: (VisibilityInfo info) {
                try {
                  setState(() => _isCollapsed = info.visibleFraction >= 1.0);
                } catch (ex) {
                  // ignored
                }
              },
              child: widget.middle!)
          : widget.middle,
      stretch: true,
      border: widget.noBorder
          ? null
          : Border(
              bottom: BorderSide(
                color: (_isCollapsed
                    ? _isDark
                        ? const Color(0xFF262626)
                        : const Color(0xFFBCBBC0)
                    : const Color(0x00000000)),
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
