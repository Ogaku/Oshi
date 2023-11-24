// ignore_for_file: prefer_const_constructors, unnecessary_this, unnecessary_cast
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/cupertino/pages/home.dart';
import 'package:oshi/interface/cupertino/views/message_compose.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/interface/cupertino/widgets/text_chip.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/data/timetables.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:oshi/interface/cupertino/views/events_timeline.dart' show EventsPage;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/v4.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import 'package:share_plus/share_plus.dart' as sharing;

// Boiler: returned to the app tab builder
StatefulWidget get timetablePage => TimetablePage();

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends VisibilityAwareState<TimetablePage> {
  final searchController = TextEditingController();
  final pageController = PageController(
      initialPage: DateTime.now().asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays);

  Timer? _everySecond;
  String searchQuery = '';
  bool isWorking = false;

  int dayDifference =
      DateTime.now().asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays;

  DateTime get selectedDate =>
      Share.session.data.student.mainClass.beginSchoolYear.asDate(utc: true).add(Duration(days: dayDifference)).asDate();

  @override
  void dispose() {
    _everySecond?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(_everySecond?.isActive ?? false)) {
      // Auto-refresh this view each second - it's static so it shouuuuld be safe...
      _everySecond = Timer.periodic(Duration(seconds: 1), (Timer t) => setState(() {}));
    }

    // Re-subscribe to all events
    Share.timetableNavigateDay.unsubscribeAll();
    Share.timetableNavigateDay.subscribe((args) {
      if (args?.value == null) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      setState(() => dayDifference =
          args!.value.asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays);

      pageController.animateToPage(dayDifference,
          duration: Duration(
              milliseconds: 250 *
                  ((args!.value.asDate().difference(Share.session.data.student.mainClass.beginSchoolYear
                              .asDate()
                              .add(Duration(days: dayDifference))
                              .asDate()))
                          .inDays)
                      .abs()
                      .clamp(1, 30)),
          curve: Curves.fastEaseInToSlowEaseOut);
    });

    return SearchableSliverNavigationBar(
        disableAddons: false,
        setState: setState,
        anchor: 0.0,
        selectedDate: selectedDate,
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
                child: TextChip(width: 110, text: DateFormat.yMd(Share.settings.config.localeCode).format(selectedDate)))),
        trailing: isWorking
            ? Container(margin: EdgeInsets.only(right: 5, top: 5), child: CupertinoActivityIndicator(radius: 12))
            : PullDownButton(
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    title: 'New event',
                    icon: CupertinoIcons.add,
                    onTap: () {},
                  ),
                  PullDownMenuDivider.large(),
                  PullDownMenuTitle(title: Text('/Titles/Pages/Schedule'.localized)),
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
                    onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => EventsPage())),
                  ),
                ],
                buttonBuilder: (context, showMenu) => GestureDetector(
                  onTap: showMenu,
                  child: const Icon(CupertinoIcons.ellipsis_circle),
                ),
              ),
        searchController: searchController,
        onChanged: (s) => setState(() => searchQuery = s),
        largeTitle: Text('/Titles/Pages/Schedule'.localized),
        child: ExpandablePageView(
            builder: (context, index) {
              DateTime selectedDate =
                  Share.session.data.student.mainClass.beginSchoolYear.asDate(utc: true).add(Duration(days: index)).asDate();
              var selectedDay = Share.session.data.timetables.timetable[selectedDate];

              // Events for the selected day/date
              var eventsToday = Share.session.events
                  .where((x) => x.category != EventCategory.homework && x.category != EventCategory.teacher)
                  .where((x) => (x.date ?? x.timeFrom).asDate() == selectedDate)
                  .where((x) =>
                      x.titleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
                      x.subtitleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
                      x.locationString.contains(RegExp(searchQuery, caseSensitive: false)))
                  .asEventWidgets(selectedDay, searchQuery, 'No events matching the query', setState);

              // Homeworks for the selected day/date
              var homeworksToday = Share.session.data.student.mainClass.events
                  .where((x) => x.category == EventCategory.homework)
                  .where((x) => x.timeTo?.asDate() == selectedDate)
                  .where((x) =>
                      x.titleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
                      x.subtitleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
                      x.locationString.contains(RegExp(searchQuery, caseSensitive: false)))
                  .orderBy((x) => x.done ? 1 : 0)
                  .asEventWidgets(selectedDay, searchQuery, 'No homeworks matching the query', setState);

              // Teacher absences for the selected day/date
              var teachersAbsentToday = Share.session.data.student.mainClass.events
                  .where((x) => x.category == EventCategory.teacher)
                  .orderBy((x) => x.sender?.name ?? '')
                  .where((x) =>
                      selectedDate.isBetween(x.timeFrom, x.timeTo ?? DateTime(2000)) ||
                      x.timeFrom.isAfter(selectedDate) && (x.timeTo?.isBefore(selectedDate.add(Duration(days: 1))) ?? false))
                  .distinct((x) => x.sender?.name ?? '')
                  .where((x) =>
                      x.titleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
                      x.subtitleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
                      x.locationString.contains(RegExp(searchQuery, caseSensitive: false)))
                  .asEventWidgets(selectedDay, searchQuery, 'No teachers matching the query', setState);

              // Lessons for the selected day, and those to be displayed
              var lessonsToDisplay = selectedDay?.lessonsStripped
                      .select((x, index) => x?.firstWhereOrDefault((y) => !y.isCanceled, defaultValue: x.first))
                      .where((x) => x != null) // Filter out all null entries
                      .select((x, index) => x!) // Remove the nullable annotation
                      .toList() ??
                  [];

              var lessonsWidget = CupertinoListSection.insetGrouped(
                header: Text(DateFormat.yMMMMEEEEd(Share.settings.config.localeCode).format(selectedDate)),
                margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
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
                            title: x.asLessonWidget(context, selectedDate, selectedDay, setState)))
                        .toList(),
              );

              return Column(
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
                            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                            additionalDividerMargin: 5,
                            children: homeworksToday.isNotEmpty ? homeworksToday : [Text('')],
                          ))),
                  // Events for today
                  Visibility(
                      visible: eventsToday.isNotEmpty,
                      child: Container(
                          margin: EdgeInsets.only(top: 20),
                          child: CupertinoListSection.insetGrouped(
                            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                            additionalDividerMargin: 5,
                            children: eventsToday.isNotEmpty ? eventsToday : [Text('')],
                          ))),
                  // Teachers absent today
                  Visibility(
                      visible: teachersAbsentToday.isNotEmpty,
                      child: Container(
                          margin: EdgeInsets.only(top: 20),
                          child: CupertinoListSection.insetGrouped(
                            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                            additionalDividerMargin: 5,
                            children: teachersAbsentToday.isNotEmpty ? teachersAbsentToday : [Text('')],
                          ))),
                ],
              );
            },
            controller: pageController,
            pageChanged: (value) => setState(() => dayDifference = value)));
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

extension EventWidgetsExtension on Iterable<Event> {
  List<Widget> asEventWidgets(
          TimetableDay? day, String searchQuery, String placeholder, void Function(VoidCallback fn) setState) =>
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
                      title: Builder(builder: (context) => x.asEventWidget(context, isNotEmpty, day, setState)))))
              .toList();
}

extension EventWidgetExtension on Event {
  Widget asEventWidget(BuildContext context, bool isNotEmpty, TimetableDay? day, void Function(VoidCallback fn) setState,
          {bool markRemoved = false, bool markModified = false, Function()? onTap}) =>
      CupertinoContextMenu.builder(
          enableHapticFeedback: true,
          actions: [
            CupertinoContextMenuAction(
              onPressed: () {
                sharing.Share.share(
                    'There\'s a "$titleString" on ${DateFormat("EEEE, MMM d, y").format(timeFrom)} ${(classroom?.name.isNotEmpty ?? false) ? ("in ${classroom?.name ?? ""}") : "at school"}');
                Navigator.of(context, rootNavigator: true).pop();
              },
              trailingIcon: CupertinoIcons.share,
              child: const Text('Share'),
            ),
            category == EventCategory.homework
                // Homework - mark as done
                ? CupertinoContextMenuAction(
                    onPressed: () {
                      Share.session.provider.markEventAsDone(parent: this).then((s) {
                        try {
                          if (s.success) {
                            setState(() => Share.session.data.student.mainClass
                                    .events[Share.session.data.student.mainClass.events.indexOf(this)] =
                                Event.from(other: this, done: true));
                          }
                        } catch (ex) {
                          // ignored
                        }
                      });
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    trailingIcon: CupertinoIcons.check_mark,
                    child: const Text('Mark as done'),
                  )
                // Event - add to calendar
                : CupertinoContextMenuAction(
                    onPressed: () {
                      try {
                        calendar.Add2Calendar.addEvent2Cal(calendar.Event(
                            title: titleString,
                            description: subtitleString,
                            location: classroom?.name,
                            startDate: timeFrom,
                            endDate: timeTo ?? timeFrom));
                      } catch (ex) {
                        // ignored
                      }
                      Navigator.of(context, rootNavigator: true).pop();
                    },
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
                        receivers: sender != null ? [sender!] : [],
                        subject: 'Pytanie o wydarzenie w dniu ${DateFormat("y.M.d").format(date ?? timeFrom)}',
                        signature:
                            '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
              },
            ),
          ],
          builder: (BuildContext context, Animation<double> animation) => eventBody(isNotEmpty, day, context,
              animation: animation, markRemoved: markRemoved, markModified: markModified, onTap: onTap));

  Widget eventBody(bool isNotEmpty, TimetableDay? day, BuildContext context,
      {Animation<double>? animation,
      bool markRemoved = false,
      bool markModified = false,
      bool useOnTap = false,
      Function()? onTap}) {
    var tag = UuidV4().generate();
    var body = GestureDetector(
        onTap: (useOnTap && onTap != null)
            ? onTap
            : (animation == null || animation.value >= CupertinoContextMenu.animationOpensAt)
                ? null
                : () => showCupertinoModalBottomSheet(
                    expand: false,
                    context: context,
                    builder: (context) => Container(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoDynamicColor.withBrightness(
                                color: const Color.fromARGB(255, 242, 242, 247),
                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                            context),
                        child: Table(
                            children: [
                          TableRow(children: [
                            Container(
                                margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                                child: Hero(
                                    tag: tag,
                                    child: eventBody(isNotEmpty, day, context,
                                        useOnTap: onTap != null,
                                        markRemoved: markRemoved,
                                        markModified: markModified,
                                        onTap: onTap)))
                          ]),
                        ]
                                .appendAllIf(
                                    attachments
                                            ?.select((x, index) => TableRow(children: [
                                                  GestureDetector(
                                                      onTap: () async {
                                                        try {
                                                          await launchUrlString(x.location);
                                                        } catch (ex) {
                                                          // ignored
                                                        }
                                                      },
                                                      child: Container(
                                                          padding: EdgeInsets.only(left: 12, top: 10, right: 10, bottom: 10),
                                                          margin: EdgeInsets.only(left: 15, top: 20, right: 15),
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                                              color: CupertinoDynamicColor.resolve(
                                                                  CupertinoColors.tertiarySystemBackground, context)),
                                                          child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Icon(CupertinoIcons.paperclip,
                                                                    color: CupertinoColors.inactiveGray),
                                                                Expanded(
                                                                    child: Container(
                                                                        margin: EdgeInsets.only(left: 15),
                                                                        child: Text(
                                                                          x.name,
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 10,
                                                                          style: TextStyle(
                                                                              fontSize: 16, fontWeight: FontWeight.w600),
                                                                        ))),
                                                              ])))
                                                ]))
                                            .toList() ??
                                        [],
                                    attachments?.isNotEmpty ?? false)
                                .appendIf(
                                    TableRow(children: [
                                      CupertinoListSection.insetGrouped(
                                          margin: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 15),
                                          additionalDividerMargin: 5,
                                          children: [
                                            CupertinoListTile(
                                              title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Title'),
                                                  Flexible(
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(titleString,
                                                                  maxLines: 10, textAlign: TextAlign.end))))
                                                ],
                                              ),
                                            ),
                                          ]
                                              .appendIf(
                                                  CupertinoListTile(
                                                      title: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('Subtitle'),
                                                      Flexible(
                                                          child: Container(
                                                              margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                              child: Opacity(
                                                                  opacity: 0.5,
                                                                  child: Text(subtitleString,
                                                                      maxLines: 10, textAlign: TextAlign.end))))
                                                    ],
                                                  )),
                                                  subtitleString.isNotEmpty)
                                              .appendIf(
                                                  CupertinoListTile(
                                                      title: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                          margin: EdgeInsets.only(right: 3),
                                                          child: Text(
                                                              category == EventCategory.teacher ? 'Teacher' : 'Added by')),
                                                      Flexible(
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(sender?.name ?? '',
                                                                  maxLines: 1, overflow: TextOverflow.ellipsis)))
                                                    ],
                                                  )),
                                                  sender?.name.isNotEmpty ?? false)
                                              .appendIf(
                                                  CupertinoListTile(
                                                      title: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(margin: EdgeInsets.only(right: 3), child: Text('Date')),
                                                      Flexible(
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(
                                                                  DateFormat.yMMMMEEEEd(Share.settings.config.localeCode)
                                                                      .format(date ?? timeFrom),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis)))
                                                    ],
                                                  )),
                                                  date != null)
                                              .appendIf(
                                                  CupertinoListTile(
                                                      title: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(margin: EdgeInsets.only(right: 3), child: Text('Classroom')),
                                                      Flexible(
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(classroom?.name ?? '',
                                                                  maxLines: 1, overflow: TextOverflow.ellipsis)))
                                                    ],
                                                  )),
                                                  classroom?.name.isNotEmpty ?? false)
                                              .appendIf(
                                                  CupertinoListTile(
                                                      title: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                          margin: EdgeInsets.only(right: 3), child: Text('Start time')),
                                                      Flexible(
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(
                                                                  DateFormat.Hm(Share.settings.config.localeCode)
                                                                      .format(timeFrom),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis)))
                                                    ],
                                                  )),
                                                  timeFrom.hour != 0)
                                              .appendIf(
                                                  CupertinoListTile(
                                                      title: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(margin: EdgeInsets.only(right: 3), child: Text('End time')),
                                                      Flexible(
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(
                                                                  DateFormat.Hm(Share.settings.config.localeCode)
                                                                      .format(timeTo ?? timeFrom),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis)))
                                                    ],
                                                  )),
                                                  timeTo != null && timeTo?.hour != 0))
                                    ]),
                                    true)))),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: (animation == null ||
                        animation.value >= CupertinoContextMenu.animationOpensAt ||
                        markModified ||
                        markRemoved ||
                        onTap != null)
                    ? CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemBackground, context)
                    : CupertinoDynamicColor.resolve(
                        CupertinoDynamicColor.withBrightness(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            darkColor: const Color.fromARGB(255, 28, 28, 30)),
                        context)),
            padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20),
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: (animation?.value ?? 0) < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                    maxWidth: (animation?.value ?? 0) < CupertinoContextMenu.animationOpensAt ? double.infinity : 260),
                child: Opacity(
                    opacity: (category == EventCategory.homework && done) ? 0.5 : 1.0,
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
                                          // Event tag
                                          Visibility(
                                              visible: (day?.lessons
                                                      .any((y) => y?.any((z) => z.lessonNo == (lessonNo ?? -1)) ?? false) ??
                                                  false),
                                              child: Container(
                                                  margin: EdgeInsets.only(top: 5, right: 6),
                                                  child: Container(
                                                    height: 10,
                                                    width: 10,
                                                    decoration: BoxDecoration(shape: BoxShape.circle, color: asColor()),
                                                  ))),
                                          // Event title
                                          Expanded(
                                              flex: 2,
                                              child: Text(
                                                titleString,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: markModified ? FontStyle.italic : null,
                                                    decoration: markRemoved ? TextDecoration.lineThrough : null),
                                              )),
                                          // Symbol/homework/days
                                          Visibility(
                                              visible: category == EventCategory.homework && done,
                                              child: Container(
                                                  margin: EdgeInsets.only(left: 4), child: Icon(CupertinoIcons.check_mark))),
                                          Visibility(
                                              visible: classroom?.name != null && category != EventCategory.teacher,
                                              child: Container(
                                                  margin: EdgeInsets.only(top: 1, left: 3),
                                                  child: Text(
                                                    classroom?.name ?? '^^',
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontStyle: markModified ? FontStyle.italic : null,
                                                        decoration: markRemoved ? TextDecoration.lineThrough : null),
                                                  ))),
                                          Visibility(
                                              visible: category == EventCategory.teacher,
                                              child: Container(
                                                  margin: EdgeInsets.only(top: 1, left: 3),
                                                  child: (timeFrom.hour != 0 && timeTo?.hour != 0) &&
                                                          (timeFrom.asDate() == timeTo?.asDate())
                                                      ? Text(
                                                          "${DateFormat.Hm(Share.settings.config.localeCode).format(timeFrom)} - ${DateFormat.Hm(Share.settings.config.localeCode).format(timeTo ?? DateTime.now())}",
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontStyle: markModified ? FontStyle.italic : null,
                                                              decoration: markRemoved ? TextDecoration.lineThrough : null),
                                                        )
                                                      : Text(
                                                          (timeFrom.month == timeTo?.month && timeFrom.day == timeTo?.day)
                                                              ? DateFormat.MMMd(Share.settings.config.localeCode)
                                                                  .format(timeTo ?? DateTime.now())
                                                              : (timeFrom.month == timeTo?.month)
                                                                  ? "${DateFormat.d(Share.settings.config.localeCode).format(timeFrom)} - ${DateFormat.MMMd(Share.settings.config.localeCode).format(timeTo ?? DateTime.now())}"
                                                                  : "${DateFormat.MMMd(Share.settings.config.localeCode).format(timeFrom)} - ${DateFormat.MMMd(Share.settings.config.localeCode).format(timeTo ?? DateTime.now())}",
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontStyle: markModified ? FontStyle.italic : null,
                                                              decoration: markRemoved ? TextDecoration.lineThrough : null),
                                                        )))
                                        ]),
                                    Visibility(
                                        visible: locationString.isNotEmpty,
                                        child: Opacity(
                                            opacity: 0.5,
                                            child: Container(
                                                padding: EdgeInsets.only(top: 4),
                                                child: Text(
                                                  locationString,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontStyle: markModified ? FontStyle.italic : null,
                                                      decoration: markRemoved ? TextDecoration.lineThrough : null),
                                                )))),
                                    Visibility(
                                        visible: subtitleString.isNotEmpty,
                                        child: Opacity(
                                            opacity: 0.5,
                                            child: Container(
                                                margin: EdgeInsets.only(top: 4),
                                                child: Text(
                                                  subtitleString.trim(),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontStyle: markModified ? FontStyle.italic : null,
                                                      decoration: markRemoved ? TextDecoration.lineThrough : null),
                                                )))),
                                  ]))
                        ])))));

    return animation == null ? body : Hero(tag: tag, child: body);
  }
}

extension LessonWidgetExtension on TimetableLesson {
  Widget asLessonWidget(
      BuildContext context, DateTime? selectedDate, TimetableDay? selectedDay, void Function(VoidCallback fn) setState,
      {bool markRemoved = false, bool markModified = false, Function()? onTap}) {
    var lessonCallButtonString = switch (Share.settings.config.lessonCallType) {
      LessonCallTypes.countFromEnd => 'last ${Share.settings.config.lessonCallTime} min',
      LessonCallTypes.countFromStart => 'first ${Share.settings.config.lessonCallTime} min',
      LessonCallTypes.halfLesson => 'half the lesson',
      LessonCallTypes.wholeLesson => 'whole lesson'
    };

    var lessonCallMessageString = switch (Share.settings.config.lessonCallType) {
      LessonCallTypes.countFromEnd => 'ostatnich ${Share.settings.config.lessonCallTime} minut lekcji',
      LessonCallTypes.countFromStart => 'pierwszych ${Share.settings.config.lessonCallTime} minut lekcji',
      LessonCallTypes.halfLesson => 'połowy',
      LessonCallTypes.wholeLesson => 'całej'
    };

    return CupertinoContextMenu.builder(
        enableHapticFeedback: true,
        actions: [
          CupertinoContextMenuAction(
            onPressed: () {
              sharing.Share.share(
                  'There\'s ${subject?.name ?? "a lesson"} on ${DateFormat("EEEE, MMM d, y").format(date)} with ${teacher?.name ?? "a teacher"}');
              Navigator.of(context, rootNavigator: true).pop();
            },
            trailingIcon: CupertinoIcons.share,
            child: const Text('Share'),
          ),
          CupertinoContextMenuAction(
            onPressed: () {
              try {
                calendar.Add2Calendar.addEvent2Cal(calendar.Event(
                    title: subject?.name ?? 'Lesson on ${DateFormat("EEEE, MMM d, y").format(date)}',
                    location: classroom?.name,
                    startDate: timeFrom ?? date,
                    endDate: timeTo ?? date));
              } catch (ex) {
                // ignored
              }
              Navigator.of(context, rootNavigator: true).pop();
            },
            trailingIcon: CupertinoIcons.calendar,
            child: const Text('Add to calendar'),
          ),
          CupertinoContextMenuAction(
            isDestructiveAction: true,
            trailingIcon: CupertinoIcons.timer,
            child: Text('Call $lessonCallButtonString'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => MessageComposePage(
                      receivers: teacher != null ? [teacher!] : [],
                      subject:
                          'Zwolnienie z $lessonCallMessageString w dniu ${DateFormat("y.M.d").format(date)}, L$lessonNo',
                      message:
                          'Dzień dobry,\n\nProszę o zwolnienie mnie z $lessonCallMessageString lekcji ${subject?.name} w dniu ${DateFormat("y.M.d").format(date)}, na $lessonNo godzinie lekcyjnej.',
                      signature:
                          '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
            },
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
                      receivers: teacher != null ? [teacher!] : [],
                      subject: 'Pytanie o lekcję w dniu ${DateFormat("y.M.d").format(date)}, L$lessonNo',
                      signature:
                          '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
            },
          ),
        ],
        builder: (BuildContext context, Animation<double> animation) => lessonBody(context, selectedDate, selectedDay,
            animation: animation, markRemoved: markRemoved, markModified: markModified, onTap: onTap));
  }

  Widget lessonBody(BuildContext context, DateTime? selectedDate, TimetableDay? selectedDay,
      {Animation<double>? animation,
      bool markRemoved = false,
      bool markModified = false,
      bool useOnTap = false,
      Function()? onTap}) {
    var events = Share.session.data.student.mainClass.events
        .where((y) => y.date == selectedDate)
        .where((y) => (y.lessonNo ?? -1) == lessonNo)
        .select((y, index) => TableRow(children: [
              Container(
                  margin: EdgeInsets.only(top: 20, left: 15, right: 15), child: y.eventBody(true, selectedDay, context))
            ]))
        .toList();

    var tag = UuidV4().generate();
    var body = GestureDetector(
        onTap: (useOnTap && onTap != null)
            ? onTap
            : (animation == null || animation.value >= CupertinoContextMenu.animationOpensAt)
                ? null
                : () => showCupertinoModalBottomSheet(
                    expand: false,
                    context: context,
                    builder: (context) => Container(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoDynamicColor.withBrightness(
                                color: const Color.fromARGB(255, 242, 242, 247),
                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                            context),
                        child: Table(
                            children: <TableRow>[
                          TableRow(children: [
                            Container(
                                margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                                child: Hero(
                                    tag: tag,
                                    child: lessonBody(context, selectedDate, selectedDay,
                                        useOnTap: onTap != null,
                                        markRemoved: markRemoved,
                                        markModified: markModified,
                                        onTap: onTap)))
                          ])
                        ].appendAllIf(events, events.isNotEmpty).appendIf(
                                TableRow(children: [
                                  CupertinoListSection.insetGrouped(
                                      margin: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 15),
                                      additionalDividerMargin: 5,
                                      children: <CupertinoListTile>[]
                                          .appendIf(
                                              CupertinoListTile(
                                                  title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Subject'),
                                                  Flexible(
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(subject?.name ?? '',
                                                                  maxLines: 3,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  textAlign: TextAlign.end))))
                                                ],
                                              )),
                                              subject?.name.isNotEmpty ?? false)
                                          .appendIf(
                                              CupertinoListTile(
                                                  title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Teacher'),
                                                  Flexible(
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(teacher?.name ?? '',
                                                                  maxLines: 1, overflow: TextOverflow.ellipsis))))
                                                ],
                                              )),
                                              teacher?.name.isNotEmpty ?? false)
                                          .appendIf(
                                              CupertinoListTile(
                                                  title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Classroom'),
                                                  Flexible(
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(classroom?.name ?? '',
                                                                  maxLines: 1, textAlign: TextAlign.end))))
                                                ],
                                              )),
                                              classroom?.name.isNotEmpty ?? false)
                                          .appendIf(
                                              CupertinoListTile(
                                                  title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Lesson no.'),
                                                  Flexible(
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(lessonNo.toString(),
                                                                  maxLines: 3,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  textAlign: TextAlign.end))))
                                                ],
                                              )),
                                              lessonNo >= 0)
                                          // Substitution details - original lesson
                                          .appendIf(
                                              CupertinoListTile(
                                                  title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Original lesson'),
                                                  Flexible(
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(substitutionDetails?.originalSubject?.name ?? '',
                                                                  maxLines: 3, textAlign: TextAlign.end))))
                                                ],
                                              )),
                                              (isCanceled || modifiedSchedule) &&
                                                  !isMovedLesson &&
                                                  (substitutionDetails?.originalSubject?.name.isNotEmpty ?? false))
                                          // Substitution details - original teacher
                                          .appendIf(
                                              CupertinoListTile(
                                                  title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Original teacher'),
                                                  Flexible(
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(substitutionDetails?.originalTeacher?.name ?? '',
                                                                  maxLines: 3, textAlign: TextAlign.end))))
                                                ],
                                              )),
                                              (isCanceled || modifiedSchedule) &&
                                                  !isMovedLesson &&
                                                  (substitutionDetails?.originalTeacher?.name.isNotEmpty ?? false))
                                          // Substitution details - moved lesson
                                          .appendIf(
                                              CupertinoListTile(
                                                  title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(isCanceled ? 'Moved to' : 'Moved from'),
                                                  Flexible(
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(
                                                                  '${DateFormat.yMd(Share.settings.config.localeCode).format(substitutionDetails?.originalDate ?? DateTime.now().asDate())}${substitutionDetails?.originalLessonNo != null ? ', L${substitutionDetails?.originalLessonNo.toString()}' : ''}',
                                                                  maxLines: 3,
                                                                  textAlign: TextAlign.end))))
                                                ],
                                              )),
                                              isMovedLesson)
                                          // Substitution details - cancelled
                                          .appendIf(
                                              CupertinoListTile(
                                                  title: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text('This lesson has been cancelled',
                                                                  maxLines: 1, textAlign: TextAlign.center))))
                                                ],
                                              )),
                                              isCanceled && !isMovedLesson))
                                ]),
                                true)))),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: (animation == null ||
                        animation.value >= CupertinoContextMenu.animationOpensAt ||
                        markModified ||
                        markRemoved ||
                        onTap != null)
                    ? CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemBackground, context)
                    : CupertinoDynamicColor.resolve(
                        CupertinoDynamicColor.withBrightness(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            darkColor: const Color.fromARGB(255, 28, 28, 30)),
                        context)),
            padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20),
            child: Opacity(
                opacity: (isCanceled ||
                        (date == DateTime.now().asDate() &&
                            (selectedDay?.dayEnd?.isAfter(DateTime.now()) ?? false) &&
                            (hourTo?.asHour(DateTime.now()).isBefore(DateTime.now()) ?? false)))
                    ? 0.5
                    : 1.0,
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: (animation?.value ?? 0) < CupertinoContextMenu.animationOpensAt
                            ? double.infinity
                            : ((modifiedSchedule || isCanceled) ? 110 : 80),
                        maxWidth: (animation?.value ?? 0) < CupertinoContextMenu.animationOpensAt ? double.infinity : 300),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children:
                                  // Event tags
                                  Share.session.data.student.mainClass.events
                                          .where((y) => y.date == selectedDate)
                                          .where((y) => (y.lessonNo ?? -1) == lessonNo)
                                          .select((y, index) => Container(
                                              margin: EdgeInsets.only(top: 5, right: 6),
                                              child: Container(
                                                height: 10,
                                                width: 10,
                                                decoration: BoxDecoration(shape: BoxShape.circle, color: y.asColor()),
                                              )) as Widget)
                                          .toList() +
                                      // The lesson block
                                      [
                                        // Lesson name
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                              subject?.name ?? 'Unknown',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: (isCanceled || modifiedSchedule || markModified)
                                                      ? FontStyle.italic
                                                      : FontStyle.normal,
                                                  decoration:
                                                      (isCanceled || markRemoved) ? TextDecoration.lineThrough : null),
                                            )),
                                        // Classroom name/symbol
                                        Container(
                                            padding: EdgeInsets.only(left: 15),
                                            child: ((animation?.value ?? 0) < CupertinoContextMenu.animationOpensAt &&
                                                    (Share.session.data.student.attendances
                                                            ?.any((y) => y.date == date && y.lessonNo == lessonNo) ??
                                                        false))
                                                ? (switch (Share.session.data.student.attendances!
                                                    .firstWhere((y) => y.date == date && y.lessonNo == lessonNo)
                                                    .type) {
                                                    AttendanceType.absent =>
                                                      Icon(CupertinoIcons.xmark, color: CupertinoColors.destructiveRed),
                                                    AttendanceType.late =>
                                                      Icon(CupertinoIcons.timer, color: CupertinoColors.systemYellow),
                                                    AttendanceType.excused => Icon(CupertinoIcons.doc_on_clipboard,
                                                        color: CupertinoColors.systemCyan),
                                                    AttendanceType.duty => Icon(CupertinoIcons.rectangle_stack_person_crop,
                                                        color: CupertinoColors.systemIndigo),
                                                    AttendanceType.present =>
                                                      Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeGreen),
                                                    AttendanceType.other =>
                                                      Icon(CupertinoIcons.question, color: CupertinoColors.inactiveGray)
                                                  })
                                                : Text(
                                                    classroom?.name ?? '',
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        fontStyle: (isCanceled || modifiedSchedule || markModified)
                                                            ? FontStyle.italic
                                                            : FontStyle.normal,
                                                        decoration:
                                                            (isCanceled || markRemoved) ? TextDecoration.lineThrough : null),
                                                  ))
                                      ]),
                          // Time and teacher details
                          Visibility(
                              visible: !(date == DateTime.now().asDate() &&
                                  (selectedDay?.dayEnd?.isAfter(DateTime.now()) ?? false) &&
                                  ((hourTo?.asHour(DateTime.now()).isBefore(DateTime.now()) ?? false) || isCanceled)),
                              child: Container(
                                  margin: EdgeInsets.only(top: 4),
                                  child: Opacity(
                                      opacity: 0.5,
                                      child: Text(
                                        detailsTimeTeacherString,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontStyle: (isCanceled || modifiedSchedule || markModified)
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                            decoration: (isCanceled || markRemoved) ? TextDecoration.lineThrough : null),
                                      )))),
                          // Substitution details - visible if context is opened
                          Visibility(
                              visible: (animation?.value ?? 0) >= CupertinoContextMenu.animationOpensAt &&
                                  (modifiedSchedule || isCanceled),
                              child: Container(
                                  margin: EdgeInsets.only(top: 4),
                                  child: Opacity(
                                      opacity: 0.5,
                                      child: Text(
                                        substitutionDetailsString,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontStyle: (isCanceled || modifiedSchedule || markModified)
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                            decoration: (isCanceled || markRemoved) ? TextDecoration.lineThrough : null),
                                      ))))
                        ])))));

    return animation == null ? body : Hero(tag: tag, child: body);
  }
}

extension DateTimeExtension on DateTime {
  bool isAfterOrSame(DateTime? other) => this == other || isAfter(other ?? DateTime.now());
  bool isBeforeOrSame(DateTime? other) => this == other || isBefore(other ?? DateTime.now());
  DateTime withTime(DateTime? other) =>
      other == null ? this : DateTime(year, month, day, other.hour, other.minute, other.second);
  DateTime asHour([DateTime? other]) => (other ?? DateTime(2000)).withTime(this);

  bool isAfterOrEqualTo(DateTime dateTime) {
    final isAtSameMomentAs = dateTime.isAtSameMomentAs(this);
    return isAtSameMomentAs | isAfter(dateTime);
  }

  bool isBeforeOrEqualTo(DateTime dateTime) {
    final isAtSameMomentAs = dateTime.isAtSameMomentAs(this);
    return isAtSameMomentAs | isBefore(dateTime);
  }

  bool isBetween(
    DateTime fromDateTime,
    DateTime toDateTime,
  ) {
    final isAfter = isAfterOrEqualTo(fromDateTime);
    final isBefore = isBeforeOrEqualTo(toDateTime);
    return isAfter && isBefore;
  }
}

extension EventColors on Event {
  Color asColor() => switch (this.category) {
        EventCategory.gathering => CupertinoColors.systemPurple, // Zebranie
        EventCategory.lecture => CupertinoColors.systemBlue, // Lektura
        EventCategory.test => CupertinoColors.systemOrange, // Test
        EventCategory.classWork => CupertinoColors.systemRed, // Praca Klasowa
        EventCategory.semCorrection => CupertinoColors.systemIndigo, // Poprawka
        EventCategory.other => CupertinoColors.inactiveGray, // Inne
        EventCategory.lessonWork => CupertinoColors.systemBrown, // Praca na Lekcji
        EventCategory.shortTest => CupertinoColors.systemCyan, // Kartkowka
        EventCategory.correction => CupertinoColors.systemIndigo, // Poprawa
        EventCategory.onlineLesson => CupertinoColors.systemGreen, // Online
        EventCategory.homework => CupertinoColors.systemYellow, // Praca domowa (horror)
        EventCategory.teacher => CupertinoColors.inactiveGray, // Nieobecnosc nauczyciela
        EventCategory.freeDay => CupertinoColors.inactiveGray, // Dzien wolny (opis)
        EventCategory.conference => CupertinoColors.systemTeal // Wywiadowka
      };

  double get cardHeight {
    var height = 180.0;

    if (subtitleString.isNotEmpty) height += 45;
    if (sender?.name.isNotEmpty ?? false) height += 45;
    if (date != null) height += 45;
    if (classroom?.name.isNotEmpty ?? false) height += 45;
    if (timeTo != null && timeTo?.hour != 0) height += 45;
    if (timeFrom.hour != 0) height += 45;

    return height;
  }
}
