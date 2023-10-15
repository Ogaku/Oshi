// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:ogaku/interface/cupertino/views/searchable_bar.dart';
import 'package:ogaku/share/share.dart';
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
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
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
                  trailing: Container(margin: EdgeInsets.only(left: 3), child: CupertinoListTileChevron()),
                  title: Container(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                      child: Container(
                                          margin: EdgeInsets.only(right: 10),
                                          child: Text(
                                            x.senderName,
                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                          ))),
                                  Opacity(
                                      opacity: 0.5,
                                      child: Text(
                                        x.sendDateString,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                      ))
                                ]),
                            Container(
                                margin: EdgeInsets.only(top: 3),
                                child: Text(
                                  x.topic,
                                  maxLines: 2,
                                  style: TextStyle(fontSize: 16),
                                )),
                            Opacity(
                                opacity: 0.5,
                                child: Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Text(
                                      x.previewString.replaceAll('\n ', '\n').replaceAll('\n\n', '\n'),
                                      maxLines: 2,
                                      style: TextStyle(fontSize: 16),
                                    ))),
                          ]))))
              .toList(),
    );

    return SearchableSliverNavigationBar(
      largeTitle: Text('Messages'),
      searchController: searchController,
      onChanged: (s) => setState(() => searchQuery = s),
      trailing: PullDownButton(
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
