// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/share/share.dart';

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
        largeHeader: false,
        filled: false,
        regularOverride: true,
        additionalDividerMargin: 5,
        header: widget.header.isNotEmpty ? widget.header : null,
        footer: widget.description.isNotEmpty ? widget.description : null,
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
                child: AdaptiveCard(regular: true, child: x.key, after: x.value.toString())))
            .cast<Widget>()
            // The 'add' menu
            .append(AdaptiveCard(
                regular: true,
                click: () {
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
                trailingElement: Share.settings.appSettings.useCupertino
                    ? null
                    : Transform.scale(
                        scale: 0.8,
                        child: Icon(CupertinoIcons.add,
                            color: (_keyController.text.isNotEmpty &&
                                    !widget.update().containsKey(_keyController.text) &&
                                    widget.validate(_valueController.text) != null)
                                ? null
                                : CupertinoColors.inactiveGray)),
                after: Share.settings.appSettings.useCupertino
                    ? Transform.scale(
                        scale: 0.8,
                        child: Icon(CupertinoIcons.add,
                            color: (_keyController.text.isNotEmpty &&
                                    !widget.update().containsKey(_keyController.text) &&
                                    widget.validate(_valueController.text) != null)
                                ? null
                                : CupertinoColors.inactiveGray))
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 50),
                        child: Share.settings.appSettings.useCupertino
                            ? CupertinoTextField(
                                onChanged: (value) => setState(() {}),
                                controller: _keyController,
                                expands: false,
                                textAlign: TextAlign.start,
                                maxLength: widget.maxKeyLength,
                                maxLengthEnforcement: MaxLengthEnforcement.enforced)
                            : TextFormField(
                                onChanged: (value) => setState(() {}),
                                controller: _keyController,
                                expands: false,
                                textAlign: TextAlign.start,
                                maxLength: widget.maxKeyLength,
                                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                decoration: InputDecoration(
                                  counterText: "",
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintTextDirection: TextDirection.ltr,
                                  fillColor: Colors.transparent,
                                ),
                              )),
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: _valueController.text.isNotEmpty ? 70 : 100),
                        child: Share.settings.appSettings.useCupertino
                            ? CupertinoTextField.borderless(
                                onChanged: (value) => setState(() {}),
                                controller: _valueController,
                                placeholder: widget.placeholder,
                                expands: false,
                                textAlign: TextAlign.end,
                                maxLength: widget.maxValueLength,
                                showCursor: _valueController.text.isNotEmpty,
                                maxLengthEnforcement: MaxLengthEnforcement.enforced)
                            : TextFormField(
                                onChanged: (value) => setState(() {}),
                                controller: _valueController,
                                expands: false,
                                textAlign: TextAlign.start,
                                maxLength: widget.maxValueLength,
                                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                decoration: InputDecoration(
                                  counterText: "",
                                  hintStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey),
                                  hintText: widget.placeholder,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintTextDirection: TextDirection.ltr,
                                  fillColor: Colors.transparent,
                                ),
                              )),
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
