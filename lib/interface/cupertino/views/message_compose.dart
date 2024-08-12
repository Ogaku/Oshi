// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/interface/cupertino/widgets/text_chip.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/share/share.dart';

class MessageComposePage extends StatefulWidget {
  const MessageComposePage({super.key, this.receivers, this.subject, this.message, this.signature});

  final List<Teacher>? receivers;
  final String? subject;
  final String? message;
  final String? signature;

  @override
  State<MessageComposePage> createState() => _MessageComposePageState();
}

class _MessageComposePageState extends State<MessageComposePage> {
  bool isWorking = false;

  List<Teacher> receivers = [];
  late TextEditingController subjectController;
  late TextEditingController messageController;
  late TextEditingController signatureController;
  TextEditingController receiverController = TextEditingController();

  @override
  void initState() {
    super.initState();
    receivers = widget.receivers ?? [];

    subjectController = TextEditingController(text: widget.subject);
    messageController = TextEditingController(text: widget.message);
    signatureController = TextEditingController(text: widget.signature);
  }

  @override
  Widget build(BuildContext context) {
    var receiversToDisplay = Share.session.data.messages.receivers
        .where((x) => x.name.contains(RegExp(receiverController.text, caseSensitive: false)));

    return SearchableSliverNavigationBar(
      anchor: 0.0,
      searchController: TextEditingController(),
      backgroundColor: CupertinoDynamicColor.withBrightness(
          color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 28, 28, 30)),
      largeTitle: subjectController.text.isEmpty
          ? Text('New message')
          : Text(subjectController.text, maxLines: 1, overflow: TextOverflow.ellipsis),
      leading: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Text('Cancel',
              style: TextStyle(color: !isWorking ? CupertinoTheme.of(context).primaryColor : CupertinoColors.inactiveGray)),
          onPressed: () async => Navigator.pop(context)),
      transitionBetweenRoutes: false,
      trailing: CupertinoButton(
          padding: EdgeInsets.all(0),
          alignment: Alignment.centerRight,
          onPressed: (receivers.isNotEmpty && subjectController.text.isNotEmpty && messageController.text.isNotEmpty)
              ? () {
                  if (isWorking) return;
                  try {
                    setState(() => isWorking = true);
                    Share.session.provider
                        .sendMessage(
                            receivers: receivers,
                            topic: subjectController.text.replaceAll('\n', ' '),
                            content: messageController.text +
                                (signatureController.text.isEmpty ? '' : '\n\n${signatureController.text}'))
                        .then((value) => setState(() => isWorking = false));
                  } on Exception catch (e) {
                    setState(() => isWorking = false);
                    if (isAndroid || isIOS) {
                      Fluttertoast.showToast(
                        msg: '$e',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                      );
                    }
                  }
                  // Close the current page
                  Navigator.pop(context);
                }
              : null,
          child: isWorking
              ? CupertinoActivityIndicator()
              : Icon(CupertinoIcons.paperplane_fill,
                  color: (receivers.isNotEmpty && subjectController.text.isNotEmpty && messageController.text.isNotEmpty)
                      ? CupertinoTheme.of(context).primaryColor
                      : CupertinoColors.inactiveGray)),
      child: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.only(right: 10, left: 10, bottom: 10, top: 15),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Text('To:', style: TextStyle(fontWeight: FontWeight.w600))),
                          ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 250),
                              child: CupertinoTextField.borderless(
                                  enabled: !isWorking,
                                  onChanged: (s) => setState(() {}),
                                  controller: receiverController,
                                  placeholder: 'Type in receivers...')),
                        ]),
                    // Receivers
                    Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            alignment: WrapAlignment.start,
                            runAlignment: WrapAlignment.start,
                            spacing: 5,
                            runSpacing: -10,
                            children: receivers
                                .select((x, index) => CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: TextChip(
                                        noMargin: true,
                                        text: x.name,
                                        radius: 20,
                                        fontSize: 14,
                                        insets: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                        fontWeight: FontWeight.w600),
                                    onPressed: () => setState(() => receivers.remove(x))))
                                .toList())),
                    // Either the receiver search or the contents
                    receiverController.text.isNotEmpty
                        ? CupertinoListSection.insetGrouped(
                            margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
                            additionalDividerMargin: 5,
                            children: receiversToDisplay.isEmpty
                                // No messages to display
                                ? [
                                    CupertinoListTile(
                                        title: Opacity(
                                            opacity: 0.5,
                                            child: Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'No receivers matching the query',
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                                ))))
                                  ]
                                // Bindable messages layout
                                : receiversToDisplay
                                    .select((x, index) => CupertinoListTile(
                                        onTap: receivers.contains(x)
                                            ? null
                                            : () => setState(() {
                                                  receivers.add(x);
                                                  receiverController.text = '';
                                                }),
                                        title: Opacity(opacity: receivers.contains(x) ? 0.3 : 1.0, child: Text(x.name))))
                                    .toList())
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                                // Subject input
                                CupertinoTextField.borderless(
                                    maxLines: null,
                                    enabled: !isWorking,
                                    onChanged: (s) => setState(() {}),
                                    controller: subjectController,
                                    placeholder: 'Subject',
                                    placeholderStyle:
                                        TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.tertiaryLabel)),
                                // Message input
                                CupertinoTextField.borderless(
                                    maxLines: null,
                                    enabled: !isWorking,
                                    onChanged: (s) => setState(() {}),
                                    controller: messageController,
                                    placeholder: 'Type in your message here...'),
                                // Signature input
                                CupertinoTextField.borderless(
                                    maxLines: null,
                                    enabled: !isWorking,
                                    onChanged: (s) => setState(() {}),
                                    controller: signatureController,
                                    placeholder: 'No Signature')
                              ])
                  ]))),
    );
  }
}
