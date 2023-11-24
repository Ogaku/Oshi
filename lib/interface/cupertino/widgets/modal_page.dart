import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoModalPage<T> extends StatefulWidget {
  const CupertinoModalPage({super.key, required this.children, required this.title, this.previousPageTitle});

  final String title;
  final String? previousPageTitle;
  final List<Widget> children;

  @override
  State<CupertinoModalPage> createState() => _CupertinoModalPageState();
}

class _CupertinoModalPageState<T> extends State<CupertinoModalPage<T>> {
  late ScrollController scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(scrollPositionUpdated);
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.removeListener(scrollPositionUpdated);
    scrollController.dispose();
  }

  void scrollPositionUpdated() {
    if (scrollController.offset >= 16 && !_isCollapsed) {
      setState(() {
        _isCollapsed = true;
      });
    } else if (scrollController.offset < 16 && _isCollapsed) {
      setState(() {
        _isCollapsed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.maybeBrightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
        backgroundColor: const CupertinoDynamicColor.withBrightness(
            color: Color.fromARGB(255, 242, 242, 247), darkColor: Color.fromARGB(255, 0, 0, 0)),
        navigationBar: CupertinoNavigationBar(
            transitionBetweenRoutes: true,
            automaticallyImplyLeading: true,
            previousPageTitle: widget.previousPageTitle ?? 'Settings',
            middle: Text(widget.title),
            border: Border(
              bottom: BorderSide(
                color: _isCollapsed ? const Color(0x4D000000) : const Color(0x00000000),
                width: 0.0,
              ),
            ),
            backgroundColor: (_isCollapsed
                ? isDark
                    ? const Color.fromRGBO(45, 45, 45, 0.5)
                    : Colors.white.withOpacity(0.5)
                : CupertinoDynamicColor.withBrightness(
                    color: const Color.fromARGB(255, 242, 242, 247).withAlpha(254),
                    darkColor: const Color.fromARGB(255, 0, 0, 0).withAlpha(254)))),
        child:
            SafeArea(
							bottom: false,
							child: SingleChildScrollView(controller: scrollController, child: Column(children: widget.children))));
  }
}
