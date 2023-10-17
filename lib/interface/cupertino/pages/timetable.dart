// ignore_for_file: prefer_const_constructors, unnecessary_this
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:ogaku/interface/cupertino/pages/home.dart';
import 'package:ogaku/interface/cupertino/widgets/searchable_bar.dart';
import 'package:ogaku/interface/cupertino/widgets/text_chip.dart';
import 'package:ogaku/models/data/event.dart';
import 'package:ogaku/share/share.dart';
import 'package:pull_down_button/pull_down_button.dart';

// Boiler: returned to the app tab builder
StatefulWidget get timetablePage => TimetablePage();

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final searchController = TextEditingController();
  final pageController = PageController(
      initialPage: DateTime.now().asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays);

  String searchQuery = '';
  bool isWorking = false;

  int dayDifference =
      DateTime.now().asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays;

  DateTime get selectedDate =>
      Share.session.data.student.mainClass.beginSchoolYear.asDate().add(Duration(days: dayDifference)).asDate();

  @override
  Widget build(BuildContext context) {
    return SearchableSliverNavigationBar(
        leading: GestureDetector(
            onTap: () => _showDialog(
                  CupertinoDatePicker(
                    initialDateTime: selectedDate,
                    mode: CupertinoDatePickerMode.date,
                    use24hFormat: true,
                    showDayOfWeek: true,
                    minimumDate: Share.session.data.student.mainClass.beginSchoolYear,
                    maximumDate: Share.session.data.student.mainClass.endSchoolYear,
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() => dayDifference =
                          newDate.asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays);

                      pageController.animateToPage(dayDifference,
                          duration: Duration(
                              milliseconds: 250 *
                                  ((newDate.asDate().difference(Share.session.data.student.mainClass.beginSchoolYear
                                              .asDate()
                                              .add(Duration(days: dayDifference))
                                              .asDate()))
                                          .inDays)
                                      .abs()
                                      .clamp(1, 30)),
                          curve: Curves.fastEaseInToSlowEaseOut);
                    },
                  ),
                ),
            child: Container(
                margin: EdgeInsets.only(top: 5, bottom: 5),
                child: TextChip(width: 110, text: DateFormat('d.MM.y').format(selectedDate)))),
        trailing: isWorking
            ? Container(margin: EdgeInsets.only(right: 5, top: 5), child: CupertinoActivityIndicator(radius: 12))
            : PullDownButton(
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    title: 'Refresh',
                    icon: CupertinoIcons.refresh,
                    onTap: () => setState(() {
                      if (isWorking) return;
                      setState(() => isWorking = true);
                      try {
                        Share.session.refresh(weekStart: selectedDate).then((value) => setState(() => isWorking = false));
                      } catch (ex) {
                        // ignored
                      }
                    }),
                  ),
                  PullDownMenuDivider.large(),
                  PullDownMenuTitle(title: Text('Schedule')),
                  PullDownMenuItem(
                    title: 'Today',
                    icon: CupertinoIcons.calendar_today,
                    onTap: () => pageController.animateToPage(
                        DateTime.now()
                            .asDate()
                            .difference(Share.session.data.student.mainClass.beginSchoolYear.asDate())
                            .inDays,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOutExpo),
                  ),
                  PullDownMenuItem(
                    title: 'Agenda',
                    icon: CupertinoIcons.list_bullet_below_rectangle,
                    onTap: () {},
                  ),
                  PullDownMenuItem(
                    title: 'New event',
                    icon: CupertinoIcons.add,
                    onTap: () {},
                  ),
                ],
                buttonBuilder: (context, showMenu) => GestureDetector(
                  onTap: showMenu,
                  child: const Icon(CupertinoIcons.ellipsis_circle),
                ),
              ),
        searchController: searchController,
        onChanged: (s) => setState(() => searchQuery = s),
        largeTitle: Text('Schedule'),
        child: PageView.builder(
            scrollBehavior: CupertinoScrollBehavior(),
            scrollDirection: Axis.horizontal,
            pageSnapping: true,
            itemBuilder: (context, index) {
              DateTime selectedDate =
                  Share.session.data.student.mainClass.beginSchoolYear.asDate().add(Duration(days: index)).asDate();

              // Events for the selected day/date
              var eventsToday = Share.session.data.student.mainClass.events
                  .where((x) => x.category != EventCategory.homework && x.category != EventCategory.teacher)
                  .where((x) => x.date == selectedDate)
                  .where((x) =>
                      x.titleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
                      x.subtitleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
                      x.locationString.contains(RegExp(searchQuery, caseSensitive: false)))
                  .asEventWidgets(searchQuery, 'No events matching the query', setState);

              // Homeworks for the selected day/date
              var homeworksToday = Share.session.data.student.mainClass.events
                  .where((x) => x.category == EventCategory.homework)
                  .where((x) => x.timeTo?.asDate() == selectedDate)
                  .where((x) =>
                      x.titleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
                      x.subtitleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
                      x.locationString.contains(RegExp(searchQuery, caseSensitive: false)))
                  .orderBy((x) => x.done ? 1 : 0)
                  .asEventWidgets(searchQuery, 'No homeworks matching the query', setState);

              // Teacher absences for the selected day/date
              var teachersAbsentToday = Share.session.data.student.mainClass.events
                  .where((x) => x.category == EventCategory.teacher)
                  .where((x) =>
                      x.timeFrom.isAfter(selectedDate) && (x.timeTo?.isBefore(selectedDate.add(Duration(days: 1))) ?? false))
                  .distinct((x) => x.sender?.name ?? '')
                  .where((x) =>
                      x.titleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
                      x.subtitleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
                      x.locationString.contains(RegExp(searchQuery, caseSensitive: false)))
                  .asEventWidgets(searchQuery, 'No teachers matching the query', setState);

              // Lessons for the selected day, and those to be displayed
              var selectedDay = Share.session.data.timetables.timetable[selectedDate];
              var lessonsToDisplay = selectedDay?.lessonsStripped
                      .select((x, index) => x?.firstWhereOrDefault((y) => !y.isCanceled, defaultValue: x.first))
                      .where((x) => x != null) // Filter out all null entries
                      .select((x, index) => x!) // Remove the nullable annotation
                      .toList() ??
                  [];

              var lessonsWidget = CupertinoListSection.insetGrouped(
                header: Text(DateFormat('EEEE, d MMMM y').format(selectedDate)),
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                additionalDividerMargin: 5,
                children: lessonsToDisplay.isEmpty
                    // No messages to display
                    ? [
                        CupertinoListTile(
                            title: Opacity(
                                opacity: 0.5,
                                child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      selectedDay == null ? 'Refresh to synchronize' : 'No lessons, yay!',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                    ))))
                      ]
                    // Bindable messages layout
                    : lessonsToDisplay
                        .select((x, index) => CupertinoListTile(
                            padding: EdgeInsets.all(0),
                            title: CupertinoContextMenu.builder(
                                actions: [
                                  CupertinoContextMenuAction(
                                    onPressed: () {},
                                    trailingIcon: CupertinoIcons.share,
                                    child: const Text('Share'),
                                  ),
                                  CupertinoContextMenuAction(
                                    onPressed: () {},
                                    trailingIcon: CupertinoIcons.calendar,
                                    child: const Text('Add to calendar'),
                                  ),
                                  CupertinoContextMenuAction(
                                    onPressed: () {},
                                    isDestructiveAction: true,
                                    trailingIcon: CupertinoIcons.chat_bubble_2,
                                    child: const Text('Inquiry'),
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
                                                  : 80,
                                              maxWidth: animation.value < CupertinoContextMenu.animationOpensAt
                                                  ? double.infinity
                                                  : 300),
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.max,
                                                    children: [
                                                      Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            x.subject?.name ?? 'Unknown',
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                                          )),
                                                      Container(
                                                          padding: EdgeInsets.only(left: 15),
                                                          child: Text(
                                                            x.classroom?.name ?? '',
                                                            style: TextStyle(fontSize: 17),
                                                          ))
                                                    ]),
                                                Container(
                                                    margin: EdgeInsets.only(top: 4),
                                                    child: Opacity(
                                                        opacity: 0.5,
                                                        child: Text(
                                                          x.detailsTimeTeacherString,
                                                          style: TextStyle(fontSize: 17),
                                                        )))
                                              ])));
                                })))
                        .toList(),
              );

              return SingleChildScrollView(
                  child: Container(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          (searchQuery.isEmpty ? lessonsWidget : Container()),
                          // Homeworks for today
                          Visibility(
                              visible: homeworksToday.isNotEmpty,
                              child: Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: CupertinoListSection.insetGrouped(
                                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                                    additionalDividerMargin: 5,
                                    children: homeworksToday.isNotEmpty ? homeworksToday : [Text('')],
                                  ))),
                          // Events for today
                          Visibility(
                              visible: eventsToday.isNotEmpty,
                              child: Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: CupertinoListSection.insetGrouped(
                                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                                    additionalDividerMargin: 5,
                                    children: eventsToday.isNotEmpty ? eventsToday : [Text('')],
                                  ))),
                          // Teachers absent today
                          Visibility(
                              visible: teachersAbsentToday.isNotEmpty,
                              child: Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: CupertinoListSection.insetGrouped(
                                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                                    additionalDividerMargin: 5,
                                    children: teachersAbsentToday.isNotEmpty ? teachersAbsentToday : [Text('')],
                                  ))),
                        ],
                      )));
            },
            controller: pageController,
            onPageChanged: (value) => setState(() => dayDifference = value)));
  }

  // This function displays a CupertinoModalPopup with a reasonable fixed height
  // which hosts CupertinoDatePicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }
}

extension EventWidgetExtension on Iterable<Event> {
  List<Widget> asEventWidgets(String searchQuery, String placeholder, void Function(VoidCallback fn) setState) => isEmpty &&
          searchQuery.isNotEmpty
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
                                  onPressed: () {},
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
                                          // Navigator.pop(context);
                                        },
                                        trailingIcon: CupertinoIcons.check_mark,
                                        child: const Text('Mark as done'),
                                      )
                                    // Event - add to calendar
                                    : CupertinoContextMenuAction(
                                        onPressed: () {},
                                        trailingIcon: CupertinoIcons.calendar,
                                        child: const Text('Add to calendar'),
                                      ),
                                CupertinoContextMenuAction(
                                  onPressed: () {},
                                  isDestructiveAction: true,
                                  trailingIcon: CupertinoIcons.chat_bubble_2,
                                  child: const Text('Inquiry'),
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
                                                            Text(
                                                              x.titleString,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                                            ),
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
                                                            Visibility(
                                                                visible: x.locationString.isNotEmpty,
                                                                child: Opacity(
                                                                    opacity: 0.5,
                                                                    child: Container(
                                                                        margin: EdgeInsets.only(top: 4),
                                                                        child: Text(
                                                                          x.locationString,
                                                                          overflow: TextOverflow.ellipsis,
                                                                          style: TextStyle(fontSize: 16),
                                                                        )))),
                                                          ])),
                                                  Visibility(
                                                      visible: x.category == EventCategory.homework && x.done,
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 4),
                                                          child: Icon(CupertinoIcons.check_mark))),
                                                  Visibility(
                                                      visible:
                                                          x.classroom?.name != null && x.category != EventCategory.teacher,
                                                      child: Container(
                                                          margin: EdgeInsets.only(top: 4),
                                                          child: Text(
                                                            x.classroom?.name ?? '^^',
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(fontSize: 16),
                                                          ))),
                                                  Visibility(
                                                      visible: x.category == EventCategory.teacher,
                                                      child: Container(
                                                          margin: EdgeInsets.only(top: 2, left: 3),
                                                          child: Text(
                                                            "${DateFormat('H:mm').format(x.timeFrom)} - ${DateFormat('H:mm').format(x.timeTo ?? DateTime.now())}",
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(fontSize: 15),
                                                          ))),
                                                ]))));
                              })))))
          .toList();
}

extension DateTimeExtension on DateTime {
  bool isAfterOrSame(DateTime? other) => this == other || isAfter(other ?? DateTime.now());
  bool isBeforeOrSame(DateTime? other) => this == other || isBefore(other ?? DateTime.now());
  DateTime withTime(DateTime? other) =>
      other == null ? this : DateTime(year, month, day, other.hour, other.minute, other.second);
  DateTime asHour(DateTime? other) => DateTime(2000).withTime(other);
}
