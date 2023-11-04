import 'package:flutter/cupertino.dart';

class CupertinoModalPage<T> extends StatefulWidget {
  const CupertinoModalPage({super.key, required this.children, required this.title});

  final String title;
  final List<Widget> children;

  @override
  State<CupertinoModalPage> createState() => _CupertinoModalPageState();
}

class _CupertinoModalPageState<T> extends State<CupertinoModalPage<T>> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: const CupertinoDynamicColor.withBrightness(
            color: Color.fromARGB(255, 242, 242, 247), darkColor: Color.fromARGB(255, 0, 0, 0)),
        navigationBar: CupertinoNavigationBar(
            transitionBetweenRoutes: false,
            automaticallyImplyLeading: true,
            previousPageTitle: 'Back',
            middle: Text(widget.title),
            border: const Border(
              bottom: BorderSide(
                color: Color(0x4D000000),
                width: 0.0,
              ),
            ),
            backgroundColor: const CupertinoDynamicColor.withBrightness(
                color: Color.fromARGB(255, 242, 242, 247), darkColor: Color.fromARGB(255, 0, 0, 0))),
        child: SingleChildScrollView(child: Column(children: widget.children)));
  }
}
