// ignore_for_file: prefer_const_constructors, unnecessary_this, unnecessary_cast
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/material/data_page.dart';
import 'package:oshi/interface/components/shim/elements/event.dart';
import 'package:oshi/interface/components/shim/page_routes.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/shared/views/grades_detailed.dart';
import 'package:oshi/interface/shared/views/new_event.dart';
import 'package:oshi/interface/components/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/interface/components/cupertino/widgets/text_chip.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:oshi/interface/shared/views/events_timeline.dart' show EventsPage;
import 'package:visibility_aware_state/visibility_aware_state.dart';

// Boiler: returned to the app tab builder
StatefulWidget get timetablePage => TimetablePage();

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends VisibilityAwareState<TimetablePage> {
  bool get isBeforeSchoolYear => DateTime.now().asDate().isBefore(Share.session.data.student.mainClass.beginSchoolYear);
  bool get isAfterSchoolYear => DateTime.now().asDate().isAfter(Share.session.data.student.mainClass.endSchoolYear);
  bool get isSchoolYear => !isBeforeSchoolYear && !isAfterSchoolYear;

  final searchController = TextEditingController(); // Notg even used anymore
  late final SegmentController segmentController;
  final pageController = PageController(
      initialPage: DateTime.now().asDate().isBefore(Share.session.data.student.mainClass.beginSchoolYear)
          ? 0
          : DateTime.now().asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays);

  Timer? _everySecond;
  bool isWorking = false;

  int dayDifference = DateTime.now().asDate().isBefore(Share.session.data.student.mainClass.beginSchoolYear)
      ? 0
      : DateTime.now().asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays;

  DateTime get selectedDate =>
      (isBeforeSchoolYear ? DateTime.now().asDate() : Share.session.data.student.mainClass.beginSchoolYear.asDate(utc: true))
          .add(Duration(days: dayDifference))
          .asDate();

  @override
  void initState() {
    super.initState();
    segmentController = SegmentController(
        segment: isBeforeSchoolYear
            ? 0
            : DateTime.now().asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays,
        scrollable: true);

    segmentController.removeListener(() => setState(() => dayDifference = segmentController.segment));
    segmentController.addListener(() => setState(() => dayDifference = segmentController.segment));
  }

  @override
  void dispose() {
    Share.refreshAll.unsubscribe(refresh);
    _everySecond?.cancel();
    super.dispose();
  }

  void refresh(args) {
    if (mounted) setState(() {});
  }

  Widget timetableBuilder(BuildContext context, dynamic index) {
    // Check the index type
    if (index is! int) return Text('errors');

    DateTime selectedDate =
        Share.session.data.student.mainClass.beginSchoolYear.asDate(utc: true).add(Duration(days: index)).asDate();
    var selectedDay = Share.session.data.timetables.timetable[selectedDate];

    // Events for the selected day/date
    var eventsToday = Share.session.events
        .where((x) => x.category != EventCategory.homework && x.category != EventCategory.teacher)
        .where((x) => (x.date ?? x.timeFrom).asDate() == selectedDate)
        .where((x) =>
            x.titleString.contains(RegExp(searchController.text, caseSensitive: false)) ||
            x.subtitleString.contains(RegExp(searchController.text, caseSensitive: false)) ||
            x.locationString.contains(RegExp(searchController.text, caseSensitive: false)))
        .asEventWidgets(selectedDay, searchController.text, 'ACCA97A8-5C58-4D65-A827-6BBE076DDC71'.localized, setState);

    // Homeworks for the selected day/date
    var homeworksToday = Share.session.events
        .where((x) => x.category == EventCategory.homework)
        .where((x) => x.timeTo?.asDate() == selectedDate || (x.timeTo == null && x.date?.asDate() == selectedDate))
        .where((x) =>
            x.titleString.contains(RegExp(searchController.text, caseSensitive: false)) ||
            x.subtitleString.contains(RegExp(searchController.text, caseSensitive: false)) ||
            x.locationString.contains(RegExp(searchController.text, caseSensitive: false)))
        .orderBy((x) => x.done ? 1 : 0)
        .asEventWidgets(selectedDay, searchController.text, '334BC7AB-6780-412F-8604-2C6BAA9F3152'.localized, setState);

    // Teacher absences for the selected day/date
    var teachersAbsentToday = Share.session.events
        .where((x) => x.category == EventCategory.teacher)
        .orderBy((x) => x.sender?.name ?? '')
        .where((x) =>
            selectedDate.isBetween(x.timeFrom, x.timeTo ?? DateTime(2000)) ||
            x.timeFrom.isAfter(selectedDate) && (x.timeTo?.isBefore(selectedDate.add(Duration(days: 1))) ?? false))
        .distinct((x) => x.sender?.name ?? '')
        .where((x) =>
            x.titleString.contains(RegExp(searchController.text, caseSensitive: false)) ||
            x.subtitleString.contains(RegExp(searchController.text, caseSensitive: false)) ||
            x.locationString.contains(RegExp(searchController.text, caseSensitive: false)))
        .asEventWidgets(selectedDay, searchController.text, 'CB4DFBFF-DC80-4787-8DAD-8046F536D65E'.localized, setState);

    // Lessons for the selected day, and those to be displayed
    var lessonsToDisplay = selectedDay?.lessonsStripped
            .select((x, index) => x?.firstWhereOrDefault((y) => !y.isCanceled, defaultValue: x.first))
            .where((x) => x != null) // Filter out all null entries
            .select((x, index) => x!) // Remove the nullable annotation
            .toList() ??
        [];

    var lessonsWidget = CardContainer(
      largeHeader: true,
      header: Share.settings.appSettings.useCupertino
          ? DateFormat.yMMMMEEEEd(Share.settings.appSettings.localeCode).format(selectedDate)
          : null,
      additionalDividerMargin: 5,
      filled: false,
      regularOverride: true,
      children: lessonsToDisplay.isEmpty
          // No messages to display
          ? [
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: AdaptiveCard(
                  centered: true,
                  secondary: true,
                  child: selectedDay == null
                      ? 'AD1F219E-A73A-45AA-9F75-574ACBA84522'.localized
                      : 'FEF84AFC-C749-4FF3-A0C2-8B5846ACD189'.localized,
                ),
              )
            ]
          // Bindable messages layout
          : lessonsToDisplay
              .select((x, index) => AdaptiveCard(
                  regular: true,
                  margin: EdgeInsets.only(left: 8, right: 8),
                  padding: EdgeInsets.only(),
                  child: x.asLessonWidget(context, selectedDate, selectedDay, setState)))
              .toList(),
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
          textScaler:
              TextScaler.linear(!Share.settings.appSettings.useCupertino && isHorizontalPhoneMode(context) ? 0.7 : 1.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          (searchController.text.isEmpty ? lessonsWidget : Container()),
          if (!Share.settings.appSettings.useCupertino &&
              (homeworksToday.isNotEmpty || eventsToday.isNotEmpty || teachersAbsentToday.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Divider(indent: 23, endIndent: 23),
            ),
          // Homeworks for today
          Visibility(
              visible: homeworksToday.isNotEmpty,
              child: Container(
                  margin: EdgeInsets.only(top: Share.settings.appSettings.useCupertino ? 20 : 0),
                  child: CardContainer(
                    filled: false,
                    regularOverride: true,
                    additionalDividerMargin: 5,
                    children: homeworksToday.isNotEmpty ? homeworksToday : [Text('')],
                  ))),
          // Events for today
          Visibility(
              visible: eventsToday.isNotEmpty,
              child: Container(
                  margin: EdgeInsets.only(top: Share.settings.appSettings.useCupertino ? 20 : 0),
                  child: CardContainer(
                    filled: false,
                    regularOverride: true,
                    additionalDividerMargin: 5,
                    children: eventsToday.isNotEmpty ? eventsToday : [Text('')],
                  ))),
          // Teachers absent today
          Visibility(
              visible: teachersAbsentToday.isNotEmpty,
              child: Container(
                  margin: EdgeInsets.only(top: Share.settings.appSettings.useCupertino ? 20 : 0),
                  child: CardContainer(
                    filled: false,
                    regularOverride: true,
                    additionalDividerMargin: 5,
                    children: teachersAbsentToday.isNotEmpty ? teachersAbsentToday : [Text('')],
                  ))),
        ],
      ),
    );
  }

  void animateToPage([DateTime? newDate, int? page]) {
    if (Share.settings.appSettings.useCupertino) {
      pageController.animateToPage(page ?? dayDifference,
          duration: Duration(
              milliseconds: newDate != null
                  ? (250 *
                      ((newDate.asDate().difference(Share.session.data.student.mainClass.beginSchoolYear
                                  .asDate()
                                  .add(Duration(days: dayDifference))
                                  .asDate()))
                              .inDays)
                          .abs()
                          .clamp(1, 30))
                  : 300),
          curve: Curves.fastEaseInToSlowEaseOut);
    } else if (segmentController.reserved is TabController) {
      (segmentController.reserved as TabController).animateTo(page ?? dayDifference,
          duration: Duration(
              milliseconds: newDate != null
                  ? (250 *
                      ((newDate.asDate().difference(Share.session.data.student.mainClass.beginSchoolYear
                                  .asDate()
                                  .add(Duration(days: dayDifference))
                                  .asDate()))
                              .inDays)
                          .abs()
                          .clamp(1, 30))
                  : 300),
          curve: Curves.fastEaseInToSlowEaseOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(_everySecond?.isActive ?? false)) {
      // Auto-refresh this view each second - it's static so it shouuuuld be safe...
      _everySecond = Timer.periodic(Duration(seconds: 1), (Timer t) => setState(() {}));
    }

    // Re-subscribe to all events
    Share.refreshAll.unsubscribe(refresh);
    Share.refreshAll.subscribe(refresh);

    Share.timetableNavigateDay.unsubscribeAll();
    Share.timetableNavigateDay.subscribe((args) {
      if (args?.value == null) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      setState(() => dayDifference =
          args!.value.asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays);

      animateToPage(args!.value.asDate());
    });

    return DataPageBase.adaptive(
      pageFlags: [
        DataPageType.refreshable,
        DataPageType.noTitleSpace,
        if (!Share.settings.appSettings.useCupertino) DataPageType.segmented,
      ].flag,
      setState: setState,
      selectedDate: selectedDate,
      leading: GestureDetector(
          onTap: () => Share.settings.appSettings.useCupertino
              ? _showDialog(
                  CupertinoDatePicker(
                    initialDateTime: selectedDate,
                    mode: CupertinoDatePickerMode.date,
                    use24hFormat: true,
                    showDayOfWeek: true,
                    minimumDate: Share.session.data.student.mainClass.beginSchoolYear,
                    maximumDate: DateTime.now()
                                .asDate()
                                .difference(Share.session.data.student.mainClass.endSchoolYear.asDate())
                                .inDays >=
                            0
                        ? DateTime.now().asDate()
                        : Share.session.data.student.mainClass.endSchoolYear,
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() => dayDifference =
                          newDate.asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays);
                      animateToPage(newDate);
                    },
                  ),
                )
              : showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: Share.session.data.student.mainClass.beginSchoolYear,
                  lastDate: DateTime.now()
                              .asDate()
                              .difference(Share.session.data.student.mainClass.endSchoolYear.asDate())
                              .inDays >=
                          0
                      ? DateTime.now().asDate()
                      : Share.session.data.student.mainClass.endSchoolYear,
                ).then((newDate) {
                  if (newDate == null) return;
                  setState(() => dayDifference =
                      newDate.asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays);
                  animateToPage(newDate);
                }),
          child: Container(
              margin: EdgeInsets.only(
                  top: Share.settings.appSettings.useCupertino ? 0 : 5,
                  bottom: 5,
                  right: Share.settings.appSettings.useCupertino ? 0 : 25),
              child:
                  TextChip(width: 110, text: DateFormat.yMd(Share.settings.appSettings.localeCode).format(selectedDate)))),
      trailing: isWorking
          ? Container(
              margin: EdgeInsets.only(right: 5, top: 5),
              child: Share.settings.appSettings.useCupertino
                  ? CupertinoActivityIndicator(radius: 12)
                  : SizedBox(height: 20, width: 20, child: CircularProgressIndicator()))
          : Stack(alignment: Alignment.bottomRight, children: [
              AdaptiveMenuButton(
                itemBuilder: (context) => [
                  AdaptiveMenuItem(
                    title: '6196CAC4-C4CE-41AB-BDB9-AF6EBBF2A5EF'.localized,
                    icon: CupertinoIcons.add,
                    onTap: () {
                      showCupertinoModalBottomSheet(context: context, builder: (context) => EventComposePage())
                          .then((value) => setState(() {}));
                    },
                  ),
                  PullDownMenuDivider.large(),
                  PullDownMenuTitle(title: Text('/Titles/Pages/Schedule'.localized)),
                  AdaptiveMenuItem(
                    title: 'B6173A9C-6BAB-426E-9F38-257AB0F1B573'.localized,
                    icon: CupertinoIcons.calendar_today,
                    onTap: () => animateToPage(
                        null,
                        isBeforeSchoolYear
                            ? 0
                            : DateTime.now()
                                .asDate()
                                .difference(Share.session.data.student.mainClass.beginSchoolYear.asDate())
                                .inDays),
                  ),
                  AdaptiveMenuItem(
                    title: '6834A472-D03D-4CC5-A91E-1A65B0C43DF8'.localized.format(
                        ((Share.session.unreadChanges.timetablesCount + Share.session.unreadChanges.eventsCount > 0)
                            ? ' (${(Share.session.unreadChanges.timetablesCount + Share.session.unreadChanges.eventsCount)})'
                            : '')),
                    icon: CupertinoIcons.list_bullet_below_rectangle,
                    onTap: () => Navigator.push(context, AdaptivePageRoute(builder: (context) => EventsPage())),
                  ),
                ],
              ),
              AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: (Share.session.data.timetables.timetable.entries
                          .where((x) => x.key.asDate().isAfterOrSame(DateTime.now().asDate()))
                          .any((x) => x.value.hasUnread))
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
      title: '/Titles/Pages/Schedule'.localized,
      children: [
        if (Share.settings.appSettings.useCupertino)
          ExpandablePageView(
              builder: timetableBuilder,
              controller: pageController,
              pageChanged: (value) => setState(() => dayDifference = value))
      ],
      segments: List.generate(
          Share.session.data.student.mainClass.beginSchoolYear
                  .difference(Share.session.data.student.mainClass.endSchoolYear)
                  .inDays
                  .abs() +
              (isSchoolYear
                  ? 0
                  : (isBeforeSchoolYear
                      ? ((DateTime.now().asDate().difference(Share.session.data.student.mainClass.beginSchoolYear.asDate()).inDays).abs() +
                          1)
                      : ((DateTime.now().asDate().difference(Share.session.data.student.mainClass.endSchoolYear.asDate()).inDays).abs() +
                          1))),
          (index) =>
              index).toMap((x) => MapEntry(
          x,
          DateFormat('EEEEE, d.MM', Share.settings.appSettings.localeCode)
              .format((isBeforeSchoolYear ? DateTime.now().asDate() : Share.session.data.student.mainClass.beginSchoolYear)
                  .add(Duration(days: x)))
              .capitalize())),
      segmentController: segmentController,
      pageBuilder: Share.settings.appSettings.useCupertino ? null : timetableBuilder,
    );
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
