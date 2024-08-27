// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/interface/shared/views/message_compose.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/models/data/messages.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:share_plus/share_plus.dart' as sharing;

class MessageDetailsPage extends StatefulWidget {
  const MessageDetailsPage({super.key, required this.message, required this.isByMe});

  final Message message;
  final bool isByMe;

  @override
  State<MessageDetailsPage> createState() => _MessageDetailsPageState();
}

class _MessageDetailsPageState extends State<MessageDetailsPage> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return DataPageBase.adaptive(
      title: widget.message.topic,
      previousPageTitle: '621EE9A3-68D0-40B1-A990-68FAD150AFAA'.localized,
      trailing: AdaptiveMenuButton(
        itemBuilder: (context) => [
          AdaptiveMenuItem(
            title: '/Share'.localized,
            icon: CupertinoIcons.share,
            onTap: () {
              sharing.Share.share(widget.isByMe
                  ? '485689BD-B015-4C7B-AADE-BC9F084B1E2B'.localized.format(
                      DateFormat("EEE, MMM d, y 'a't hh:mm a").format(widget.message.sendDate),
                      Share.session.data.student.account.name,
                      Share.session.data.student.mainClass.name,
                      widget.message.topic,
                      widget.message.content)
                  : 'B4118707-9AF7-45E7-8759-59C00CE240C4'.localized.format(
                      DateFormat("EEE, MMM d, y 'a't hh:mm a").format(widget.message.sendDate),
                      widget.message.sender?.name,
                      widget.message.topic,
                      widget.message.content));
            },
          ),
          PullDownMenuDivider.large(),
          AdaptiveMenuItem(
            title: widget.isByMe
                ? 'DC48985E-AA43-4507-AF74-DAF3A385B6C1'.localized
                : 'D1D2C948-7EC7-4966-9AD0-686269DF0BE1'.localized,
            icon: CupertinoIcons.reply,
            onTap: () => showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => MessageComposePage(
                    receivers: widget.isByMe ? [] : (widget.message.sender != null ? [widget.message.sender!] : []),
                    subject: widget.isByMe
                        ? 'F77E1795-3404-4BCA-A173-80AFF744AAA1'.localized.format(widget.message.topic)
                        : '47FC297B-63E7-46E6-AEF1-7343A8BF8D08'.localized.format(widget.message.topic),
                    signature: widget.isByMe
                        ? 'C14AF35B-469F-4E81-A8EA-B348267E8455'.localized.format(
                            DateFormat("EEE, MMM d, y 'a't hh:mm a").format(widget.message.sendDate),
                            Share.session.data.student.account.name,
                            Share.session.data.student.mainClass.name,
                            widget.message.topic,
                            widget.message.content)
                        : 'AF66B98F-C6F5-480F-87F3-49FCFDD3BBA2'.localized.format(
                            Share.session.data.student.account.name,
                            Share.session.data.student.mainClass.name,
                            DateFormat("EEE, MMM d, y 'a't hh:mm a").format(widget.message.sendDate),
                            widget.message.sender?.name,
                            widget.message.topic,
                            widget.message.content))),
          ),
          AdaptiveMenuItem(
            title: 'Delete',
            icon: CupertinoIcons.trash,
            isDestructive: true,
            onTap: () {
              // Close the current page
              Navigator.of(context).pop();

              try {
                setState(() {
                  (widget.isByMe ? Share.session.data.messages.sent : Share.session.data.messages.received)
                      .remove(widget.message);
                });
                Share.session.provider.moveMessageToTrash(parent: widget.message, byMe: widget.isByMe);
              } on Exception catch (e) {
                if (isAndroid || isIOS) {
                  Fluttertoast.showToast(
                    msg: '$e',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                  );
                }
              }
            },
          ),
        ],
      ),
      children: [
        Visibility(
            visible: widget.message.hasAttachments,
            child: CardContainer(
              header: widget.message.hasAttachments ? null : Text(''),
              additionalDividerMargin: 5,
              children: widget.message.attachments
                      ?.toList()
                      .select((x, index) => GestureDetector(
                          onTap: () async {
                            try {
                              await launchUrlString(x.location);
                            } catch (ex) {
                              // ignored
                            }
                          },
                          child: Container(
                              padding: EdgeInsets.only(left: 12, top: 10, right: 10, bottom: 10),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.paperclip, color: CupertinoColors.inactiveGray),
                                    Expanded(
                                        child: Container(
                                            margin: EdgeInsets.only(left: 15),
                                            child: Text(
                                              x.name,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            ))),
                                  ]))))
                      .toList()
                      .cast() ??
                  [],
            )),
        CardContainer(additionalDividerMargin: 5, filled: false, children: [
          Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Text(
                                    widget.message.senderName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ))),
                          Container(
                              margin: EdgeInsets.only(top: 1),
                              child: Opacity(
                                  opacity: 0.5,
                                  child: Text(
                                    widget.message.sendDateString,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                  ))),
                        ]),
                    Visibility(
                      visible: widget.isByMe && widget.message.readDate != null,
                      child: Container(
                          margin: EdgeInsets.only(top: 1),
                          child: Opacity(
                              opacity: 0.5,
                              child: Text(
                                widget.message.readDateString,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                              ))),
                    ),
                    // The message content
                    Container(
                        padding: EdgeInsets.only(top: 10),
                        child: SelectableLinkify(
                            options: LinkifyOptions(humanize: false),
                            onOpen: (link) async {
                              try {
                                await launchUrlString(link.url);
                              } catch (ex) {
                                // ignored
                              }
                            },
                            text: widget.message.content ?? '2B6C42AB-FD8A-4DC1-A4EE-58D2235AE1FD'.localized,
                            style: TextStyle(fontSize: 16)))
                  ]))
        ]),
      ],
    );
  }
}
