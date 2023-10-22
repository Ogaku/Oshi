// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:oshi/interface/cupertino/views/message_detailed.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/messages.dart';
import 'package:oshi/share/share.dart';
import 'package:pull_down_button/pull_down_button.dart';

// Boiler: returned to the app tab builder
StatefulWidget get messagesPage => MessagesPage();

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final searchController = TextEditingController();

  String searchQuery = '';
  bool showInbox = true;
  bool isWorking = false;

  @override
  Widget build(BuildContext context) {
    var messagesToDisplay = (showInbox ? Share.session.data.messages.received : Share.session.data.messages.sent)
        .where((x) =>
            x.topic.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.sendDateString.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.previewString.contains(RegExp(searchQuery, caseSensitive: false)) ||
            (x.content?.contains(RegExp(searchQuery, caseSensitive: false)) ?? false) ||
            x.senderName.contains(RegExp(searchQuery, caseSensitive: false)))
        .toList();

    var messagesWidget = CupertinoListSection.insetGrouped(
      margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
      additionalDividerMargin: 5,
      children: messagesToDisplay.isEmpty
          // No messages to display
          ? [
              CupertinoListTile(
                  title: Opacity(
                      opacity: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'No messages matching the query',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          // Bindable messages layout
          : messagesToDisplay
              .select((x, index) => CupertinoListTile(
                  padding: EdgeInsets.all(0),
                  title: CupertinoContextMenu.builder(
                      actions: [
                        CupertinoContextMenuAction(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                          trailingIcon: CupertinoIcons.share,
                          child: const Text('Share'),
                        ),
                        CupertinoContextMenuAction(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                          isDestructiveAction: true,
                          trailingIcon: CupertinoIcons.trash,
                          child: const Text('Delete'),
                        ),
                      ],
                      builder: (BuildContext context, Animation<double> animation) {
                        return GestureDetector(
                            onTap: () {
                              if (isWorking) return;
                              setState(() => isWorking = true);

                              Share.session.provider.fetchMessageContent(parent: x, byMe: !showInbox).then((result) {
                                setState(() => isWorking = false);

                                if (result.message == null && result.result != null) x.updateMessageData(result.result!);
                                if (x.content?.isEmpty ?? true) return;
                                if (showInbox) x.readDate = DateTime.now();

                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => MessageDetailsPage(
                                              message: x,
                                              isByMe: !showInbox,
                                            )));
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    color: CupertinoDynamicColor.resolve(
                                        CupertinoDynamicColor.withBrightness(
                                            color: const Color.fromARGB(255, 255, 255, 255),
                                            darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                        context)),
                                padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20),
                                child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxHeight:
                                            animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                                        maxWidth:
                                            animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 250),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Visibility(
                                                    visible: !x.read,
                                                    child: Container(
                                                        margin: EdgeInsets.only(top: 5, right: 6),
                                                        child: Container(
                                                          height: 10,
                                                          width: 10,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape.circle, color: CupertinoColors.activeBlue),
                                                        ))),
                                                Expanded(
                                                    child: Container(
                                                        margin: EdgeInsets.only(right: 10),
                                                        child: Text(
                                                          x.senderName,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                                        ))),
                                                Visibility(
                                                  visible: x.hasAttachments,
                                                  child: Transform.scale(
                                                      scale: 0.6,
                                                      child: Icon(CupertinoIcons.paperclip,
                                                          color: CupertinoColors.inactiveGray)),
                                                ),
                                                Container(
                                                    margin: EdgeInsets.only(top: 1),
                                                    child: Opacity(
                                                        opacity: 0.5,
                                                        child: Text(
                                                          x.sendDateString,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                                        )))
                                              ]),
                                          Container(
                                              margin: EdgeInsets.only(top: 3),
                                              child: Text(
                                                x.topic,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 16),
                                              )),
                                          Opacity(
                                              opacity: 0.5,
                                              child: Container(
                                                  margin: EdgeInsets.only(top: 5),
                                                  child: Text(
                                                    x.previewString.replaceAll('\n ', '\n').replaceAll('\n\n', '\n'),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: 16),
                                                  ))),
                                        ]))));
                      })))
              .toList(),
    );

    return SearchableSliverNavigationBar(
      largeTitle: Text('Messages'),
      searchController: searchController,
      onChanged: (s) => setState(() => searchQuery = s),
      trailing: isWorking
          ? Container(margin: EdgeInsets.only(right: 5, top: 5), child: CupertinoActivityIndicator(radius: 12))
          : PullDownButton(
              itemBuilder: (context) => [
                PullDownMenuItem(
                  title: 'New',
                  icon: CupertinoIcons.add,
                  onTap: () {},
                ),
                PullDownMenuDivider.large(),
                PullDownMenuTitle(title: Text('Folders')),
                PullDownMenuItem(
                  title: 'Received',
                  icon: showInbox ? CupertinoIcons.tray_fill : CupertinoIcons.tray,
                  onTap: () => setState(() => showInbox = true),
                ),
                PullDownMenuItem(
                  title: 'Sent',
                  icon: showInbox ? CupertinoIcons.paperplane : CupertinoIcons.paperplane_fill,
                  onTap: () => setState(() => showInbox = false),
                )
              ],
              buttonBuilder: (context, showMenu) => GestureDetector(
                onTap: showMenu,
                child: const Icon(CupertinoIcons.ellipsis_circle),
              ),
            ),
      children: [messagesWidget],
    );
  }
}

extension MessageUpdateExtension on Message {
  void updateMessageData(Message other) {
    id = other.id;
    url = other.url;
    topic = other.topic;
    content = other.content;
    preview = other.preview;
    hasAttachments = other.hasAttachments;
    sender = other.sender;
    sendDate = other.sendDate;
    readDate = other.readDate;
    attachments = other.attachments;
    receivers = other.receivers;
  }
}
