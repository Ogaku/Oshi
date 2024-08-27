// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:format/format.dart';
import 'package:oshi/interface/components/cupertino/widgets/text_chip.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';

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
      title: subjectController.text.isEmpty ? 'B8C5F980-D32F-42C9-A7E0-FF7667884776'.localized : subjectController.text,
      childOverride: false,
      leading: Align(
          alignment: Alignment.centerLeft,
          child: AdaptiveButton(title: 'D91ED34B-BB94-4EFF-8DF8-D5F4FF8906BF'.localized, click: isWorking ? null : () async => Navigator.pop(context))),
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
                                (signatureController.text.isEmpty ? '' : 'F263B8B0-0EFA-4486-836D-ED1FF801B2C2'.localized.format(signatureController.text)))
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
                                    placeholder: 'EECC0427-E5ED-4A10-96D4-734FE2AA7804'.localized)),
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
                                                    '81B09857-201A-4036-807F-7A32F0C23575'.localized,
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
                                    placeholder: 'AC7FCED9-3CEA-4C69-9512-8B409015DF2C'.localized,
                                    enabled: !isWorking,
                                    setState: setState,
                                  ),
                                  // Message input
                                  AdaptiveTextField(
                                    controller: messageController,
                                    secondary: true,
                                    placeholder: 'DFE8DC1D-FB74-48C0-9016-0F03A5EBD128'.localized,
                                    enabled: !isWorking,
                                    setState: setState,
                                  ),
                                  // Signature input
                                  AdaptiveTextField(
                                    controller: signatureController,
                                    secondary: true,
                                    placeholder: 'EB947AC4-561E-4D63-9EAD-7E80C18C48B9'.localized,
                                    enabled: !isWorking,
                                    setState: setState,
                                  ),
                                ])
                    ])))
      ],
    );
  }
}
