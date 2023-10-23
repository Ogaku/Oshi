// ignore_for_file: prefer_const_constructors, unnecessary_this
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/cupertino/pages/home.dart';
import 'package:oshi/interface/cupertino/views/message_compose.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/share/share.dart';
import 'package:pull_down_button/pull_down_button.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final searchController = TextEditingController();
  String searchQuery = '';

  bool showTeachers = false;
  bool showHomeworks = true;
  bool showCorrections = true;

  @override
  Widget build(BuildContext context) {
    // Group by date, I know IT'S A DAMN STRING, but we're saving on custom controls
    var eventsToDisplayByDate = Share.session.data.student.mainClass.events
        .where((x) => (showTeachers ? true : x.category != EventCategory.teacher))
        .where((x) => (x.date ?? x.timeFrom).isAfter(DateTime.now().add(Duration(days: -1)).asDate()))
        .where((x) =>
            x.titleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.subtitleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.locationString.contains(RegExp(searchQuery, caseSensitive: false)))
        .orderBy((x) => x.date ?? x.timeFrom)
        .groupBy((x) => DateFormat('EEEE, d MMMM y').format(x.date ?? x.timeFrom))
        .toList();

    // This is gonna be a veeery long list, as there are no expanders in cupertino
    var attendanceWidgets = eventsToDisplayByDate
        .select((element, index) => CupertinoListSection.insetGrouped(
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            header: Text(element.key),
            additionalDividerMargin: 5,
            children: element.isEmpty
                // No messages to display
                ? [
                    CupertinoListTile(
                        title: Opacity(
                            opacity: 0.5,
                            child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'No attendances',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                ))))
                  ]
                // Bindable messages layout
                : element.toList().asEventWidgets(searchQuery, 'No events matching the query', setState)))
        .toList();

    return SearchableSliverNavigationBar(
        setState: setState,
        trailing: PullDownButton(
          itemBuilder: (context) => [
            PullDownMenuTitle(title: Text('Filters')),
            PullDownMenuItem(
              title: 'Homeworks',
              icon: showHomeworks ? CupertinoIcons.book_fill : CupertinoIcons.book,
              onTap: () => setState(() => showHomeworks = !showHomeworks),
            ),
            PullDownMenuItem(
              title: 'Absent teachers',
              icon: showTeachers ? CupertinoIcons.person_badge_minus_fill : CupertinoIcons.person_badge_minus,
              onTap: () => setState(() => showTeachers = !showTeachers),
            ),
          ],
          buttonBuilder: (context, showMenu) => GestureDetector(
            onTap: showMenu,
            child: const Icon(CupertinoIcons.ellipsis_circle),
          ),
        ),
        largeTitle: Text('Agenda'),
        searchController: searchController,
        onChanged: (s) => setState(() => searchQuery = s),
        children: [SingleChildScrollView(child: Column(children: attendanceWidgets))]);
  }
}

extension EventWidgetExtension on Iterable<Event> {
  List<Widget> asEventWidgets(String searchQuery, String placeholder, void Function(VoidCallback fn) setState) =>
      isEmpty && searchQuery.isNotEmpty
          ? [
              CupertinoListTile(
                  title: Opacity(
                      opacity: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            placeholder,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          : this
              .select((x, index) => Visibility(
                  visible: isNotEmpty,
                  child: CupertinoListTile(
                      padding: EdgeInsets.all(0),
                      title: Builder(
                          builder: (context) => CupertinoContextMenu.builder(
                                  actions: [
                                    CupertinoContextMenuAction(
                                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                                      trailingIcon: CupertinoIcons.share,
                                      child: const Text('Share'),
                                    ),
                                    x.category == EventCategory.homework
                                        // Homework - mark as done
                                        ? CupertinoContextMenuAction(
                                            onPressed: () {
                                              Share.session.provider.markEventAsDone(parent: x).then((s) {
                                                if (s.success) setState(() => x.done = true);
                                              });
                                              Navigator.of(context, rootNavigator: true).pop();
                                            },
                                            trailingIcon: CupertinoIcons.check_mark,
                                            child: const Text('Mark as done'),
                                          )
                                        // Event - add to calendar
                                        : CupertinoContextMenuAction(
                                            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                                            trailingIcon: CupertinoIcons.calendar,
                                            child: const Text('Add to calendar'),
                                          ),
                                    CupertinoContextMenuAction(
                                      isDestructiveAction: true,
                                      trailingIcon: CupertinoIcons.chat_bubble_2,
                                      child: const Text('Inquiry'),
                                      onPressed: () {
                                        Navigator.of(context, rootNavigator: true).pop();
                                        showCupertinoModalBottomSheet(
                                            context: context,
                                            builder: (context) => MessageComposePage(
                                                receivers: x.sender != null ? [x.sender!] : [],
                                                subject:
                                                    'Pytanie do wydarzenia w dniu ${DateFormat("y.M.d").format(x.date ?? x.timeFrom)}',
                                                signature:
                                                    '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                                      },
                                    ),
                                  ],
                                  builder: (BuildContext context, Animation<double> animation) {
                                    return Container(
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
                                                maxHeight: animation.value < CupertinoContextMenu.animationOpensAt
                                                    ? double.infinity
                                                    : 100,
                                                maxWidth: animation.value < CupertinoContextMenu.animationOpensAt
                                                    ? double.infinity
                                                    : 260),
                                            child: Opacity(
                                                opacity: (x.category == EventCategory.homework && x.done) ? 0.5 : 1.0,
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                          flex: 2,
                                                          child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisSize: MainAxisSize.max,
                                                              children: [
                                                                Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.max,
                                                                    children: [
                                                                      // Event title
                                                                      Expanded(
                                                                          flex: 2,
                                                                          child: Text(
                                                                            x.titleString,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                                fontSize: 17, fontWeight: FontWeight.w600),
                                                                          )),
                                                                      // Symbol/homework/days
                                                                      Visibility(
                                                                          visible:
                                                                              x.category == EventCategory.homework && x.done,
                                                                          child: Container(
                                                                              margin: EdgeInsets.only(left: 4),
                                                                              child: Icon(CupertinoIcons.check_mark))),
                                                                      Visibility(
                                                                          visible: x.classroom?.name != null &&
                                                                              x.category != EventCategory.teacher,
                                                                          child: Container(
                                                                              margin: EdgeInsets.only(top: 1, left: 3),
                                                                              child: Text(
                                                                                x.classroom?.name ?? '^^',
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(fontSize: 16),
                                                                              ))),
                                                                      Visibility(
                                                                          visible: x.category == EventCategory.teacher,
                                                                          child: Container(
                                                                              margin: EdgeInsets.only(top: 1, left: 3),
                                                                              child: (x.timeFrom.hour != 0 &&
                                                                                      x.timeTo?.hour != 0)
                                                                                  ? Text(
                                                                                      "${DateFormat('H:mm').format(x.timeFrom)} - ${DateFormat('H:mm').format(x.timeTo ?? DateTime.now())}",
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      style: TextStyle(fontSize: 15),
                                                                                    )
                                                                                  : Text(
                                                                                      "${DateFormat('d').format(x.timeFrom)} - ${DateFormat('d MMM').format(x.timeTo ?? DateTime.now())}",
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      style: TextStyle(fontSize: 15),
                                                                                    )))
                                                                    ]),
                                                                Visibility(
                                                                    visible: x.locationString.isNotEmpty,
                                                                    child: Opacity(
                                                                        opacity: 0.5,
                                                                        child: Container(
                                                                            padding: EdgeInsets.only(top: 4),
                                                                            child: Text(
                                                                              x.locationString,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(fontSize: 16),
                                                                            )))),
                                                                Visibility(
                                                                    visible: x.subtitleString.isNotEmpty,
                                                                    child: Opacity(
                                                                        opacity: 0.5,
                                                                        child: Container(
                                                                            margin: EdgeInsets.only(top: 4),
                                                                            child: Text(
                                                                              x.subtitleString.trim(),
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 2,
                                                                              style: TextStyle(fontSize: 16),
                                                                            )))),
                                                              ]))
                                                    ]))));
                                  })))))
              .toList();
}
