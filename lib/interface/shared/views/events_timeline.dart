// ignore_for_file: prefer_const_constructors, unnecessary_this
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/shared/pages/timetable.dart';
import 'package:oshi/interface/shared/views/new_event.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/data/timetables.dart';
import 'package:oshi/share/share.dart';
import 'package:pull_down_button/pull_down_button.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  bool showTeachers = false;
  bool showHomeworks = true;

  List<Widget> eventWidgets([String query = '']) {
    // Group by date, I know IT'S A DAMN STRING, but we're saving on custom controls
    var thingsToDisplayByDate = Share.session.events
        .where((x) => (showTeachers ? true : x.category != EventCategory.teacher))
        .where((x) => (x.date ?? x.timeFrom).isAfter(DateTime.now().add(Duration(days: -1)).asDate()))
        .where((x) =>
            x.titleString.contains(RegExp(query, caseSensitive: false)) ||
            x.subtitleString.contains(RegExp(query, caseSensitive: false)) ||
            x.locationString.contains(RegExp(query, caseSensitive: false)))
        .select((x, index) => AgendaEvent(event: x))
        .appendAll(Share.session.data.timetables.timetable.entries
            .select((x, index) => x.value.lessons
                .select((y, index) => y?.where((z) => z.modifiedSchedule || z.isCanceled))
                .selectMany((w, index) => w?.toList() ?? <TimetableLesson>[]))
            .selectMany((w, index) => w)
            .where((x) => x.date.asDate().isAfterOrSame(DateTime.now().asDate()))
            .where((x) =>
                (x.subject?.name.contains(RegExp(query, caseSensitive: false)) ?? false) ||
                (x.teacher?.name.contains(RegExp(query, caseSensitive: false)) ?? false) ||
                x.classroomString.contains(RegExp(query, caseSensitive: false)))
            .select((x, index) => AgendaEvent(lesson: x))
            .toList())
        .orderBy((x) => x.date)
        .groupBy((x) => DateFormat.yMMMMEEEEd(Share.settings.appSettings.localeCode).format(x.date))
        .toList();

    return thingsToDisplayByDate
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
                : element.toList().asEventWidgets(null, query, 'No events matching the query', setState)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DataPageBase.adaptive(
        pageFlags: [
          DataPageType.searchable,
          DataPageType.refreshable,
          DataPageType.segmentedSticky,
        ].flag,
        setState: setState,
        trailing: AdaptiveMenuButton(
          itemBuilder: (context) => [
            AdaptiveMenuItem(
              title: 'New event',
              icon: CupertinoIcons.add,
              onTap: () {
                showCupertinoModalBottomSheet(context: context, builder: (context) => EventComposePage())
                    .then((value) => setState(() {}));
              },
            ),
            PullDownMenuDivider.large(),
            PullDownMenuTitle(title: Text('Filters')),
            AdaptiveMenuItem(
              title:
                  'Homeworks${((Share.session.unreadChanges.homeworksCount > 0) ? ' (${(Share.session.unreadChanges.homeworksCount)})' : '')}',
              icon: showHomeworks ? CupertinoIcons.book_fill : CupertinoIcons.book,
              onTap: () => setState(() => showHomeworks = !showHomeworks),
            ),
            AdaptiveMenuItem(
              title: 'Absent teachers',
              icon: showTeachers ? CupertinoIcons.person_badge_minus_fill : CupertinoIcons.person_badge_minus,
              onTap: () => setState(() => showTeachers = !showTeachers),
            ),
          ],
        ),
        title: 'Agenda',
        searchBuilder: (_, controller) => eventWidgets(controller.text),
        children: [SingleChildScrollView(child: Column(children: eventWidgets()))]);
  }
}

class AgendaEvent {
  final Event? event;
  final TimetableLesson? lesson;

  DateTime get date => ((event?.date ?? event?.timeFrom) ?? (lesson?.date ?? lesson?.timeFrom))?.asDate() ?? DateTime.now();

  AgendaEvent({this.event, this.lesson});
}
