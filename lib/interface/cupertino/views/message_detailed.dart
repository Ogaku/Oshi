// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:oshi/interface/cupertino/widgets/navigation_bar.dart';
import 'package:oshi/models/data/messages.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
    return CupertinoPageScaffold(
      backgroundColor: const CupertinoDynamicColor.withBrightness(
          color: Color.fromARGB(255, 242, 242, 247), darkColor: Color.fromARGB(255, 0, 0, 0)),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        anchor: ((widget.message.topic.length / 20).round() - 1).clamp(0, 5) * 0.045,
        slivers: <Widget>[
          SliverNavigationBar(
            threshold: 57.0 + (30 * ((widget.message.topic.length / 20).round() - 1).clamp(0, 5)),
            previousPageTitle: 'Back',
            largeTitle: Text(
              widget.message.topic,
              maxLines: (widget.message.topic.length / 20).round().clamp(0, 5),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            scrollController: scrollController,
            middle: Text(''),
            trailing: PullDownButton(
              itemBuilder: (context) => [
                PullDownMenuItem(
                  title: 'Share',
                  icon: CupertinoIcons.share,
                  onTap: () {},
                ),
                PullDownMenuDivider.large(),
                PullDownMenuItem(
                  title: 'Reply',
                  icon: CupertinoIcons.reply,
                  onTap: () {},
                ),
                PullDownMenuItem(
                  title: 'Delete',
                  icon: CupertinoIcons.trash,
                  isDestructive: true,
                  onTap: () {},
                ),
              ],
              buttonBuilder: (context, showMenu) => GestureDetector(
                onTap: showMenu,
                child: const Icon(CupertinoIcons.ellipsis_circle),
              ),
            ),
          ),
          SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                  margin: const EdgeInsets.only(bottom: 60, top: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Visibility(
                          visible: widget.message.hasAttachments,
                          child: CupertinoListSection.insetGrouped(
                            header: widget.message.hasAttachments ? null : Text(''),
                            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
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
                                        padding: EdgeInsets.only(left: 12, top: 8, right: 10, bottom: 10),
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
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                      ))),
                                            ]))))
                                .toList(),
                          )),
                      CupertinoListSection.insetGrouped(
                          margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                          additionalDividerMargin: 5,
                          children: [
                            Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                                              options: LinkifyOptions(humanize: true),
                                              onOpen: (link) async {
                                                try {
                                                  await launchUrlString(link.url);
                                                } catch (ex) {
                                                  // ignored
                                                }
                                              },
                                              text: widget.message.content ?? 'No content to display',
                                              style: TextStyle(fontSize: 15)))
                                    ]))
                          ]),
                    ],
                  ))),
        ],
      ),
    );
  }
}
