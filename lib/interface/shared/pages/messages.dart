// ignore_for_file: prefer_const_constructors, unnecessary_cast
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/shim/page_routes.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/views/message_compose.dart';
import 'package:oshi/interface/shared/views/message_detailed.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/models/data/announcement.dart';
import 'package:oshi/models/data/messages.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:share_plus/share_plus.dart' as sharing;
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

// Boiler: returned to the app tab builder
StatefulWidget get messagesPage => MessagesPage();

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  MessageFolders _folder = MessageFolders.inbox;
  bool isWorking = false;

  SegmentController segmentController = SegmentController(
    segment: MessageFolders.inbox,
    scrollable: true,
  );

  @override
  void dispose() {
    Share.refreshAll.unsubscribe(refresh);
    super.dispose();
  }

  void refresh(args) {
    if (mounted) setState(() {});
  }

  List<Widget> messagesWidget([String query = '', MessageFolders folder = MessageFolders.inbox, bool filled = true]) {
    var messagesToDisplay = (switch (folder) {
      MessageFolders.inbox => Share.session.data.messages.received,
      MessageFolders.outbox => Share.session.data.messages.sent,
      _ => <Message>[]
    })
        .where((x) =>
            x.topic.contains(RegExp(query, caseSensitive: false)) ||
            x.sendDateString.contains(RegExp(query, caseSensitive: false)) ||
            x.previewString.contains(RegExp(query, caseSensitive: false)) ||
            (x.content?.contains(RegExp(query, caseSensitive: false)) ?? false) ||
            x.senderName.contains(RegExp(query, caseSensitive: false)))
        .orderByDescending((element) => element.sendDate)
        .toList()
        .select((element, index) => (message: element, announcement: null as Announcement?));

    if (folder == MessageFolders.announcements) {
      messagesToDisplay = Share.session.data.student.mainClass.unit.announcements
              ?.where((x) =>
                  x.subject.contains(RegExp(query, caseSensitive: false)) ||
                  x.content.contains(RegExp(query, caseSensitive: false)) ||
                  (x.contact?.name.contains(RegExp(query, caseSensitive: false)) ?? false))
              .orderByDescending((x) => x.startDate)
              .select((x, index) => (
                    message: Message(
                        id: x.read ? 1 : 0,
                        topic: x.subject,
                        content: x.content,
                        sender: x.contact ?? Teacher(firstName: Share.session.data.student.mainClass.unit.name),
                        sendDate: x.startDate,
                        readDate: x.endDate),
                    announcement: x
                  ))
              .toList() ??
          [];
    }

    return <Widget>[
      CardContainer(
        additionalDividerMargin: 5,
        filled: messagesToDisplay.isNotEmpty && filled,
        children: messagesToDisplay.isEmpty
            // No messages to display
            ? [
                AdaptiveCard(
                    secondary: true,
                    centered: true,
                    child: folder == MessageFolders.announcements
                        ? (query.isEmpty ? 'No announcements, yet...' : 'No announcements matching the query')
                        : (query.isEmpty ? 'No messages, yet...' : 'No messages matching the query'))
              ]
            // Bindable messages layout
            : messagesToDisplay
                .select((x, index) => SwipeActionCell(
                    key: UniqueKey(),
                    backgroundColor: Colors.transparent,
                    trailingActions: <SwipeAction>[]
                        .appendIf(
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
                                  try {
                                    setState(() {
                                      (folder == MessageFolders.outbox
                                              ? Share.session.data.messages.sent
                                              : Share.session.data.messages.received)
                                          .remove(x.message);
                                      isWorking = true;
                                    });
                                    Share.session.provider
                                        .moveMessageToTrash(parent: x.message, byMe: folder == MessageFolders.outbox)
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
                                },
                                color: CupertinoColors.destructiveRed),
                            folder != MessageFolders.announcements)
                        .append(SwipeAction(
                            content: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: CupertinoColors.systemBlue,
                              ),
                              child: Icon(
                                CupertinoIcons.share,
                                color: Colors.white,
                              ),
                            ),
                            onTap: (CompletionHandler handler) => sharing.Share.share(folder == MessageFolders.outbox
                                ? 'On ${DateFormat("EEE, MMM d, y 'a't hh:mm a").format(x.message.sendDate)} ${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name} wrote:\n"${x.message.topic}\n\n${x.message.preview}[...]"'
                                : 'On ${DateFormat("EEE, MMM d, y 'a't hh:mm a").format(x.message.sendDate)} ${x.message.sender?.name} wrote:\n"${x.message.topic}\n\n${x.message.preview}[...]"'),
                            color: CupertinoColors.systemBlue))
                        .toList(),
                    child: CupertinoContextMenu.builder(
                        enableHapticFeedback: true,
                        actions: [
                          CupertinoContextMenuAction(
                            onPressed: () {
                              sharing.Share.share(folder == MessageFolders.outbox
                                  ? 'On ${DateFormat("EEE, MMM d, y 'a't hh:mm a").format(x.message.sendDate)} ${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name} wrote:\n"${x.message.topic}\n\n${x.message.preview}[...]"'
                                  : 'On ${DateFormat("EEE, MMM d, y 'a't hh:mm a").format(x.message.sendDate)} ${x.message.sender?.name} wrote:\n"${x.message.topic}\n\n${x.message.preview}[...]"');
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            trailingIcon: CupertinoIcons.share,
                            child: const Text('Share'),
                          )
                        ]
                            .appendIf(
                                CupertinoContextMenuAction(
                                  isDestructiveAction: true,
                                  trailingIcon: CupertinoIcons.trash,
                                  child: const Text('Delete'),
                                  onPressed: () {
                                    if (isWorking) return;
                                    try {
                                      setState(() {
                                        (folder == MessageFolders.outbox
                                                ? Share.session.data.messages.sent
                                                : Share.session.data.messages.received)
                                            .remove(x.message);
                                        isWorking = true;
                                      });
                                      Share.session.provider
                                          .moveMessageToTrash(parent: x.message, byMe: folder == MessageFolders.outbox)
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
                                    Navigator.of(context, rootNavigator: true).pop();
                                  },
                                ),
                                folder != MessageFolders.announcements)
                            .appendIf(
                                CupertinoContextMenuAction(
                                  isDestructiveAction: true,
                                  trailingIcon: CupertinoIcons.news,
                                  child: const Text('Mark as unread'),
                                  onPressed: () {
                                    try {
                                      setState(() {
                                        Share.session.data.messages.received.remove(x.message);
                                        Share.session.data.messages.received
                                            .add(Message.from(other: x.message, readDate: DateTime(2000)));
                                      });
                                      Share.refreshAll.broadcast();
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
                                    // Close the current page
                                    Navigator.of(context, rootNavigator: true).pop();
                                  },
                                ),
                                Share.session.settings.devMode && folder == MessageFolders.inbox)
                            .toList(),
                        builder: (BuildContext swipeContext, Animation<double> animation) => GestureDetector(
                            child: AdaptiveCard(
                                click: animation.value < CupertinoContextMenu.animationOpensAt
                                    ? () => openMessage(message: x.message, announcement: x.announcement, folder: folder)
                                    : null,
                                child: Container(
                                  decoration: Share.settings.appSettings.useCupertino
                                      ? BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                          color: CupertinoDynamicColor.resolve(
                                              CupertinoDynamicColor.withBrightness(
                                                  color: const Color.fromARGB(255, 255, 255, 255),
                                                  darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                              context))
                                      : null,
                                  padding: Share.settings.appSettings.useCupertino
                                      ? (animation.value >= CupertinoContextMenu.animationOpensAt
                                          ? EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20)
                                          : EdgeInsets.only(top: 15, bottom: 15))
                                      : null,
                                  child: Table(children: [
                                    TableRow(children: [
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Visibility(
                                                visible: (!x.message.read && folder == MessageFolders.inbox) ||
                                                    (x.message.id != 1 && folder == MessageFolders.announcements),
                                                child: Container(
                                                    margin: EdgeInsets.only(top: 5, right: 6),
                                                    child: Container(
                                                      height: 10,
                                                      width: 10,
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: CupertinoTheme.of(context).primaryColor),
                                                    ))),
                                            Expanded(
                                                child: Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: Text(
                                                      x.message.senderName,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                                    ))),
                                            Visibility(
                                              visible: x.message.hasAttachments,
                                              child: Transform.scale(
                                                  scale: 0.6,
                                                  child:
                                                      Icon(CupertinoIcons.paperclip, color: CupertinoColors.inactiveGray)),
                                            ),
                                            Container(
                                                margin: EdgeInsets.only(top: 1),
                                                child: Opacity(
                                                    opacity: 0.5,
                                                    child: Text(
                                                      folder == MessageFolders.announcements
                                                          ? (x.message.sendDate.month == x.message.readDate?.month &&
                                                                  x.message.sendDate.year == x.message.readDate?.year &&
                                                                  x.message.sendDate.day != x.message.readDate?.day
                                                              ? '${DateFormat.MMMd(Share.settings.appSettings.localeCode).format(x.message.sendDate)} - ${DateFormat.d(Share.settings.appSettings.localeCode).format(x.message.readDate ?? DateTime.now())}'
                                                              : '${DateFormat.MMMd(Share.settings.appSettings.localeCode).format(x.message.sendDate)} - ${DateFormat(x.message.sendDate.year == x.message.readDate?.year ? 'MMMd' : 'yMMMd', Share.settings.appSettings.localeCode).format(x.message.readDate ?? DateTime.now())}')
                                                          : x.message.sendDateString,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                                    )))
                                          ]),
                                    ]),
                                    TableRow(children: [
                                      Container(
                                          margin: EdgeInsets.only(top: 3),
                                          child: Text(
                                            x.message.topic,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16),
                                          )),
                                    ]),
                                    TableRow(children: [
                                      Opacity(
                                          opacity: 0.5,
                                          child: Container(
                                              margin: EdgeInsets.only(top: 5),
                                              child: Text(
                                                x.message.previewString.replaceAll('\n ', '\n').replaceAll('\n\n', '\n'),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 16),
                                              ))),
                                    ]),
                                  ]),
                                ))))))
                .toList(),
      )
    ].prepend(SizedBox(height: messagesToDisplay.isNotEmpty ? (filled ? 10 : 15) : 0)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Re-subscribe to all events
    Share.refreshAll.unsubscribe(refresh);
    Share.refreshAll.subscribe(refresh);

    Share.messagesNavigate.unsubscribeAll();
    Share.messagesNavigate.subscribe((args) {
      setState(
          () => _folder = ((args?.value.receivers?.isNotEmpty ?? false) ? MessageFolders.outbox : MessageFolders.inbox));
      openMessage(
          message: args?.value,
          folder: ((args?.value.receivers?.isNotEmpty ?? false) ? MessageFolders.outbox : MessageFolders.inbox));
    });

    Share.messagesNavigateAnnouncement.unsubscribeAll();
    Share.messagesNavigateAnnouncement.subscribe((args) {
      setState(() => _folder = MessageFolders.announcements);
      openMessage(message: args?.value.message, announcement: args?.value.parent, folder: MessageFolders.announcements);
    });

    if (!Share.settings.appSettings.useCupertino) {
      segmentController.removeListener(() => setState(() => _folder = segmentController.segment));
      segmentController.addListener(() => setState(() => _folder = segmentController.segment));
    }

    return DataPageBase.adaptive(
      pageFlags: [
        DataPageType.searchable,
        DataPageType.refreshable,
        DataPageType.boxedPage,
        if (!Share.settings.appSettings.useCupertino) DataPageType.segmented,
      ].flag,
      setState: setState,
      title: switch (_folder) {
        MessageFolders.announcements => '/Titles/Pages/Messages/Announcements'.localized,
        MessageFolders.outbox => '/Titles/Pages/Messages/Sent'.localized,
        MessageFolders.inbox || _ => '/Titles/Pages/Messages/Inbox'.localized
      },
      segments: Share.settings.appSettings.useCupertino
          ? null
          : {
              MessageFolders.inbox: '/Titles/Pages/Messages/Inbox'.localized,
              MessageFolders.outbox: '/Titles/Pages/Messages/Sent'.localized,
              MessageFolders.announcements: '/Titles/Pages/Messages/Announcements'.localized
            },
      segmentController: segmentController,
      searchBuilder: (_, controller) => messagesWidget(controller.text, _folder, false),
      trailing: isWorking
          ? Container(margin: EdgeInsets.only(right: 5, top: 5), child: CupertinoActivityIndicator(radius: 12))
          : Stack(alignment: Alignment.bottomRight, children: [
              PullDownButton(
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    title: 'New',
                    icon: CupertinoIcons.add,
                    onTap: () {
                      showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => MessageComposePage(
                              signature:
                                  '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                    },
                  ),
                  PullDownMenuDivider.large(),
                  PullDownMenuTitle(title: Text('Folders')),
                  PullDownMenuItem(
                    title: '/Titles/Pages/Messages/Inbox'.localized +
                        (Share.session.data.messages.received.any((x) => !x.read)
                            ? ' (${Share.session.data.messages.received.count((x) => !x.read)})'
                            : ''),
                    icon: _folder == MessageFolders.inbox ? CupertinoIcons.tray_fill : CupertinoIcons.tray,
                    onTap: () => setState(() => _folder = MessageFolders.inbox),
                  ),
                  PullDownMenuItem(
                    title: '/Titles/Pages/Messages/Sent'.localized,
                    icon: _folder == MessageFolders.outbox ? CupertinoIcons.paperplane_fill : CupertinoIcons.paperplane,
                    onTap: () => setState(() => _folder = MessageFolders.outbox),
                  ),
                  PullDownMenuItem(
                    title: '/Titles/Pages/Messages/Announcements'.localized +
                        ((Share.session.data.student.mainClass.unit.announcements?.any((x) => !x.read) ?? false)
                            ? ' (${(Share.session.data.student.mainClass.unit.announcements?.count((x) => !x.read) ?? 1)})'
                            : ''),
                    icon: _folder == MessageFolders.announcements ? CupertinoIcons.bell_fill : CupertinoIcons.bell,
                    onTap: () => setState(() => _folder = MessageFolders.announcements),
                  )
                ],
                buttonBuilder: (context, showMenu) => GestureDetector(
                  onTap: showMenu,
                  child: const Icon(CupertinoIcons.ellipsis_circle),
                ),
              ),
              AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: (Share.session.data.messages.received.any((x) => !x.read) ||
                          ((Share.session.data.student.mainClass.unit.announcements?.any((x) => !x.read) ?? false)))
                      ? 1.0
                      : 0.0,
                  child: Container(
                      margin: EdgeInsets.only(),
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: CupertinoTheme.of(context).primaryColor),
                      )))
            ]),
      children: messagesWidget('', _folder),
    );
  }

  void openMessage({Message? message, Announcement? announcement, required MessageFolders folder}) {
    if (message == null || isWorking) return;
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();

    try {
      if (folder == MessageFolders.announcements) {
        if (announcement != null) {
          try {
            Share.session.provider.markAnnouncementAsViewed(parent: announcement);
            setState(() {
              Share.session.data.student.mainClass.unit
                      .announcements?[Share.session.data.student.mainClass.unit.announcements?.indexOf(announcement) ?? -1] =
                  Announcement.from(other: announcement, read: true);
              Share.settings.save();
            });
          } catch (ex) {
            // ignored
          }
        }

        Navigator.push(
            context,
            AdaptivePageRoute(
                builder: (context) => MessageDetailsPage(
                      message: message!,
                      isByMe: false,
                    )));
      } else {
        setState(() => isWorking = true);

        Share.session.provider.fetchMessageContent(parent: message, byMe: folder == MessageFolders.outbox).then((result) {
          setState(() => isWorking = false);

          if (result.message == null && result.result != null && folder == MessageFolders.inbox) {
            var index = Share.session.data.messages.received.indexOf(message!);
            Share.session.data.messages.received[index] = Message.from(other: result.result!);
            message = Share.session.data.messages.received[index]; // Update x too
          }
          if (result.message == null && result.result != null && folder == MessageFolders.outbox) {
            var index = Share.session.data.messages.sent.indexOf(message!);
            Share.session.data.messages.sent[index] = Message.from(other: result.result!);
            message = Share.session.data.messages.sent[index]; // Update x too
          }

          if (result.result?.content?.isEmpty ?? true) return;
          if (folder == MessageFolders.inbox) {
            Share.session.data.messages.received[Share.session.data.messages.received.indexOf(message!)] =
                Message.from(other: result.result, readDate: DateTime.now());
          }

          Navigator.push(
              context,
              AdaptivePageRoute(
                  builder: (context) => MessageDetailsPage(
                        message: result.result ?? (message!),
                        isByMe: folder == MessageFolders.outbox,
                      )));

          Share.settings.save();
        });
      }
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
  }
}

enum MessageFolders { inbox, outbox, announcements }
