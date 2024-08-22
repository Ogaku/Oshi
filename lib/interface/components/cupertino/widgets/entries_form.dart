// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:oshi/interface/shared/containers.dart';

class EntriesForm<T> extends StatefulWidget {
  const EntriesForm(
      {super.key,
      this.header = '',
      this.description = '',
      this.placeholder = 'Key',
      required this.update,
      required this.validate,
      this.maxKeyLength = 3,
      this.maxValueLength = 5});

  final String header;
  final String description;
  final String placeholder;

  final int maxKeyLength;
  final int maxValueLength;

  final Map<String, T> Function<T>([Map<String, T>?]) update;
  final T? Function(String) validate;

  @override
  State<EntriesForm> createState() => _EntriesFormState();
}

class _EntriesFormState<T> extends State<EntriesForm<T>> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

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
        children: widget
            .update()
            .entries
            // All entries
            .select((x, index) => SwipeActionCell(
                key: UniqueKey(),
                backgroundColor: Colors.transparent,
                trailingActions: <SwipeAction>[
                  SwipeAction(
                      performsFirstActionWithFullSwipe: true,
                      content: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: CupertinoColors.destructiveRed,
                        ),
                        child: Icon(
                          CupertinoIcons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onTap: (CompletionHandler handler) async {
                        await handler(true);
                        setState(() => widget.update(widget.update().without(x.key)));
                      },
                      color: CupertinoColors.destructiveRed),
                ],
                child: CupertinoListTile(
                    title: Text(x.key, overflow: TextOverflow.ellipsis),
                    trailing: Opacity(opacity: 0.5, child: Text(x.value.toString())))))
            .cast<Widget>()
            // The 'add' menu
            .append(CupertinoListTile(
                onTap: () {
                  var result = widget.validate(_valueController.text);
                  if (!(_keyController.text.isNotEmpty &&
                      !widget.update().containsKey(_keyController.text) &&
                      result != null)) {
                    return; // Commit validation
                  }

                  widget.update(widget.update().append(_keyController.text, result));
                  setState(() {});

                  _keyController.text = ''; // Clear parent's key
                  _valueController.text = ''; // Clear paren't value
                },
                trailing: Transform.scale(
                    scale: 0.8,
                    child: Icon(CupertinoIcons.add,
                        color: (_keyController.text.isNotEmpty &&
                                !widget.update().containsKey(_keyController.text) &&
                                widget.validate(_valueController.text) != null)
                            ? null
                            : CupertinoColors.inactiveGray)),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 50),
                        child: CupertinoTextField(
                            onChanged: (value) => setState(() {}),
                            controller: _keyController,
                            expands: false,
                            textAlign: TextAlign.start,
                            maxLength: widget.maxKeyLength,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced)),
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: _valueController.text.isNotEmpty ? 70 : 100),
                        child: CupertinoTextField.borderless(
                            onChanged: (value) => setState(() {}),
                            controller: _valueController,
                            placeholder: widget.placeholder,
                            expands: false,
                            textAlign: TextAlign.end,
                            maxLength: widget.maxValueLength,
                            showCursor: _valueController.text.isNotEmpty,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced)),
                  ],
                )))
            .toList());
  }
}

extension RemoveInPlaceExtension<T, U> on Map<T, U> {
  Map<T, U> without(T key) {
    var map = {...this};
    map.remove(key);
    return map;
  }

  Map<T, U> append(T key, U value) {
    var map = {...this};
    map[key] = value;
    return map;
  }
}
