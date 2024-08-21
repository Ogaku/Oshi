// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oshi/interface/components/cupertino/widgets/text_chip.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
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

    return DataPageBase.adaptive(
      pageFlags: [
        DataPageType.noTitleSpace,
        DataPageType.noTransitions,
        DataPageType.alternativeBackground,
      ].flag,
      title: subjectController.text.isEmpty ? 'New message' : subjectController.text,
      leading: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Text('Cancel',
              style: TextStyle(color: !isWorking ? CupertinoTheme.of(context).primaryColor : CupertinoColors.inactiveGray)),
          onPressed: () async => Navigator.pop(context)),
      trailing: CupertinoButton(
          padding: EdgeInsets.only(right: Share.settings.appSettings.useCupertino ? 0 : 10),
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
              ? (Share.settings.appSettings.useCupertino
                  ? CupertinoActivityIndicator(radius: 12)
                  : SizedBox(height: 20, width: 20, child: CircularProgressIndicator()))
              : Icon(CupertinoIcons.paperplane_fill,
                  color: (receivers.isNotEmpty && subjectController.text.isNotEmpty && messageController.text.isNotEmpty)
                      ? CupertinoTheme.of(context).primaryColor
                      : CupertinoColors.inactiveGray)),
      children: [
        SingleChildScrollView(
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
                                child: AdaptiveTextField(
                                    enabled: !isWorking,
                                    secondary: true,
                                    setState: setState,
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
                          ? CardContainer(
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                              additionalDividerMargin: 5,
                              children: receiversToDisplay.isEmpty
                                  // No messages to display
                                  ? [
                                      AdaptiveCard(
                                          child: Opacity(
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
                                      .select((x, index) => AdaptiveCard(
                                          hideChevron: true,
                                          click: receivers.contains(x)
                                              ? null
                                              : () => setState(() {
                                                    receivers.add(x);
                                                    receiverController.text = '';
                                                  }),
                                          child: Opacity(opacity: receivers.contains(x) ? 0.3 : 1.0, child: Text(x.name))))
                                      .toList())
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                  // Subject input
                                  AdaptiveTextField(
                                    controller: subjectController,
                                    placeholder: 'Subject',
                                    enabled: !isWorking,
                                    setState: setState,
                                  ),
                                  // Message input
                                  AdaptiveTextField(
                                    controller: messageController,
                                    secondary: true,
                                    placeholder: 'Type in your message here...',
                                    enabled: !isWorking,
                                    setState: setState,
                                  ),
                                  // Signature input
                                  AdaptiveTextField(
                                    controller: signatureController,
                                    secondary: true,
                                    placeholder: 'No Signature',
                                    enabled: !isWorking,
                                    setState: setState,
                                  ),
                                ])
                    ])))
      ],
    );
  }
}
