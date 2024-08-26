// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/share/extensions.dart';

typedef Callback<T> = void Function(T value);

class OptionEntry<T> {
  final String name;
  final T value;
  final Widget? decoration;

  OptionEntry({required this.name, required this.value, this.decoration});
}

class OptionsForm<T> extends StatefulWidget {
  const OptionsForm(
      {super.key,
      required this.options,
      this.selection,
      required this.update,
      this.description = '',
      this.pop = true,
      this.header = ''});

  final String header;
  final String description;

  final T? selection;
  final bool pop;

  final List<OptionEntry<T>> options;

  final Callback<T> update;

  @override
  State<OptionsForm> createState() => _OptionsFormState();
}

class _OptionsFormState<T> extends State<OptionsForm<T>> {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
        additionalDividerMargin: 5,
        header: widget.header.isNotEmpty
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Opacity(
                    opacity: 0.5, child: Text(widget.header, style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal))))
            : null,
        footer: widget.description.isNotEmpty
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Opacity(opacity: 0.5, child: Text(widget.description, style: TextStyle(fontSize: 13))))
            : null,
        children: widget.options
            .select((x, index) => CupertinoListTile(
                onTap: () {
                  widget.update(x.value);
                  if (widget.pop) {
                    Navigator.of(context).pop();
                  }
                },
                title: Row(
                    children: <Widget>[Flexible(child: Text(x.name, overflow: TextOverflow.ellipsis))]
                        .prependIf(x.decoration ?? Container(), x.decoration != null)),
                trailing: widget.selection == x.value
                    ? Transform.scale(scale: 0.8, child: Icon(CupertinoIcons.check_mark))
                    : null))
            .toList());
  }
}
