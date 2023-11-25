// ignore_for_file: prefer_const_constructors, unnecessary_this
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oshi/interface/cupertino/pages/home.dart';
import 'package:oshi/interface/cupertino/pages/timetable.dart';
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

  @override
  Widget build(BuildContext context) {
    // Group by date, I know IT'S A DAMN STRING, but we're saving on custom controls
    var eventsToDisplayByDate = Share.session.events
        .where((x) => (showTeachers ? true : x.category != EventCategory.teacher))
        .where((x) => (x.date ?? x.timeFrom).isAfter(DateTime.now().add(Duration(days: -1)).asDate()))
        .where((x) =>
            x.titleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.subtitleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.locationString.contains(RegExp(searchQuery, caseSensitive: false)))
        .orderBy((x) => x.date ?? x.timeFrom)
        .groupBy((x) => DateFormat.yMMMMEEEEd(Share.settings.appSettings.localeCode).format(x.date ?? x.timeFrom))
        .toList();

    var eventWidgets = eventsToDisplayByDate
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
                                  'No events to display',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                ))))
                  ]
                // Bindable messages layout
                : element.toList().asEventWidgets(null, searchQuery, 'No events matching the query', setState)))
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
        children: [SingleChildScrollView(child: Column(children: eventWidgets))]);
  }
}
