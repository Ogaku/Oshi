// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:oshi/interface/cupertino/pages/home.dart';

class OptionEntry {
  final String name;
  final dynamic value;
  final Widget? decoration;

  OptionEntry({required this.name, required this.value, this.decoration});
}

class OptionsPage extends StatefulWidget {
  const OptionsPage(
      {super.key, required this.title, required this.options, this.selection, required this.update, this.description = ''});

  final String title;
  final String description;
  final dynamic selection;

  final List<OptionEntry> options;

  final Function(dynamic) update;

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.withBrightness(
          color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 28, 28, 30)),
      navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: false,
          automaticallyImplyLeading: true,
          previousPageTitle: 'Back',
          middle: Text(widget.title),
          border: null,
          backgroundColor: const CupertinoDynamicColor.withBrightness(
              color: Color.fromARGB(255, 242, 242, 247), darkColor: Color.fromARGB(255, 0, 0, 0))),
      child: CupertinoListSection.insetGrouped(
          additionalDividerMargin: 5,
          footer: widget.description.isNotEmpty
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Opacity(opacity: 0.5, child: Text(widget.description, style: TextStyle(fontSize: 13))))
              : null,
          children: widget.options
              .select((x, index) => CupertinoListTile(
                  onTap: () {
                    widget.update(x.value);
                    Navigator.of(context).pop();
                  },
                  title: Row(
                      children: [Text(x.name, overflow: TextOverflow.ellipsis)]
                          .prependIf(x.decoration ?? Container(), x.decoration != null)),
                  trailing: widget.selection == x.value
                      ? Transform.scale(scale: 0.8, child: Icon(CupertinoIcons.check_mark))
                      : null))
              .toList()),
    );
  }
}
