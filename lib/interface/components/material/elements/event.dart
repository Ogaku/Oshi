// ignore_for_file: prefer_const_constructors
import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/cupertino/application.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/shared/views/events_timeline.dart';
import 'package:oshi/interface/shared/views/message_compose.dart';
import 'package:oshi/interface/shared/views/new_event.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/data/timetables.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import 'package:share_plus/share_plus.dart' as sharing;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

extension TimelineWidgetsExtension on Iterable<AgendaEvent> {
  List<Widget> asEventWidgets(
          TimetableDay? day, String searchQuery, String placeholder, void Function(VoidCallback fn) setState) =>
      isEmpty && searchQuery.isNotEmpty
          ? [
              AdaptiveCard(
                  centered: true,
                  secondary: true,
                  child: Opacity(
                      opacity: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            placeholder,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          : select((x, index) => Visibility(
              visible: isNotEmpty,
              child: AdaptiveCard(
                  child: Builder(
                      builder: (context) =>
                          x.event?.asEventWidget(context, isNotEmpty, day, setState) ??
                          x.lesson?.asLessonWidget(context, null, day, setState) ??
                          Text(''))))).toList();
}

extension EventColors on Event {
  Color asColor() => switch (category) {
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
        EventCategory.conference => CupertinoColors.systemTeal, // Wywiadowka
        EventCategory.admin => CupertinoColors.systemMint // Admin
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

extension EventWidgetsExtension on Iterable<Event> {
  List<Widget> asEventWidgets(
          TimetableDay? day, String searchQuery, String placeholder, void Function(VoidCallback fn) setState) =>
      isEmpty && searchQuery.isNotEmpty
          ? [
              AdaptiveCard(
                  centered: true,
                  secondary: true,
                  child: Opacity(
                      opacity: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            placeholder,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          : select((x, index) => Visibility(
              visible: isNotEmpty,
              child: AdaptiveCard(
                  child: Builder(builder: (context) => x.asEventWidget(context, isNotEmpty, day, setState))))).toList();
}

extension EventWidgetExtension on Event {
  Widget asEventWidget(BuildContext context, bool isNotEmpty, TimetableDay? day, void Function(VoidCallback fn) setState,
          {bool markRemoved = false, bool markModified = false, Function()? onTap}) =>
      AdaptiveMenuButton(
          itemBuilder: (context) => [
                AdaptiveMenuItem(
                  onTap: () {
                    sharing.Share.share(
                        'There\'s a "$titleString" on ${DateFormat("EEEE, MMM d, y").format(timeFrom)} ${(classroom?.name.isNotEmpty ?? false) ? ("in ${classroom?.name ?? ""}") : "at school"}');
                  },
                  icon: CupertinoIcons.share,
                  title: 'Share',
                ),
                category == EventCategory.homework
                    // Homework - mark as done
                    ? AdaptiveMenuItem(
                        onTap: () {
                          if (Share.session.data.student.mainClass.events.contains(this)) {
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
                          } else {
                            // Must be a custom event
                            try {
                              setState(() => Share.session.customEvents[Share.session.customEvents.indexOf(this)] =
                                  Event.from(other: this, done: true));
                            } catch (ex) {
                              // ignored
                            }
                          }
                        },
                        icon: CupertinoIcons.check_mark,
                        title: 'Mark as done',
                      )
                    // Event - add to calendar
                    : AdaptiveMenuItem(
                        onTap: () {
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
                        },
                        icon: CupertinoIcons.calendar,
                        title: 'Add to calendar',
                      ),
              ]
                  .appendIf(
                      AdaptiveMenuItem(
                        icon: CupertinoIcons.pencil,
                        title: 'Edit',
                        onTap: () {
                          try {
                            showMaterialModalBottomSheet(
                                context: context,
                                builder: (context) => EventComposePage(
                                      previous: this,
                                    )).then((value) => setState(() {}));
                          } catch (ex) {
                            // ignored
                          }
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                      isOwnEvent || isSharedEvent)
                  .appendIf(
                      AdaptiveMenuItem(
                        icon: CupertinoIcons.chat_bubble_2,
                        title: 'Inquiry',
                        onTap: () {
                          showMaterialModalBottomSheet(
                              context: context,
                              builder: (context) => MessageComposePage(
                                  receivers: sender != null ? [sender!] : [],
                                  subject: 'Pytanie o wydarzenie w dniu ${DateFormat("y.M.d").format(date ?? timeFrom)}',
                                  signature:
                                      '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                        },
                      ),
                      !isOwnEvent)
                  .appendIf(
                      AdaptiveMenuItem(
                        icon: CupertinoIcons.delete,
                        title: 'Delete',
                        onTap: () {
                          setState(() => Share.session.customEvents.remove(this));
                          Share.settings.save();
                        },
                      ),
                      isOwnEvent)
                  .appendIf(
                      AdaptiveMenuItem(
                        icon: CupertinoIcons.delete,
                        title: 'Delete',
                        onTap: () {
                          setState(() => Share.session.sharedEvents.remove(this));
                          Share.settings.save();
                          unshare(); // Unshare the event using the API
                        },
                      ),
                      isSharedEvent),
          longPressOnly: true,
          child: eventBody(isNotEmpty, day, context,
              animation: null, markRemoved: markRemoved, markModified: markModified, onTap: onTap));

  Widget eventBody(bool isNotEmpty, TimetableDay? day, BuildContext context,
      {Animation<double>? animation,
      bool markRemoved = false,
      bool markModified = false,
      bool useOnTap = false,
      bool disableTap = false,
      Function()? onTap}) {
    var tag = Uuid().v4();
    var body = AdaptiveCard(
        regular: true,
        click: disableTap
            ? null
            : ((useOnTap && onTap != null)
                ? onTap
                : () => showMaterialModalBottomSheet(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    expand: false,
                    context: context,
                    builder: (context) => Table(
                            children: [
                          TableRow(children: [
                            Container(
                                margin: EdgeInsets.only(top: 15, left: 10, right: 10),
                                child: Hero(
                                    tag: tag,
                                    child: eventBody(isNotEmpty, day, context,
                                        useOnTap: onTap != null,
                                        markRemoved: markRemoved,
                                        markModified: markModified,
                                        disableTap: true,
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
                                .append(TableRow(children: [
                                  CardContainer(
                                      filled: false,
                                      additionalDividerMargin: 5,
                                      regularOverride: true,
                                      children: <Widget>[
                                        Divider(),
                                        AdaptiveCard(
                                          child: 'Title',
                                          regular: true,
                                          after: titleString,
                                        ),
                                      ]
                                          .appendIf(
                                              AdaptiveCard(
                                                child: 'Subtitle',
                                                regular: true,
                                                after: subtitleString,
                                              ),
                                              subtitleString.isNotEmpty)
                                          .appendIf(
                                              AdaptiveCard(
                                                child: category == EventCategory.teacher ? 'Teacher' : 'Added by',
                                                regular: true,
                                                after: sender?.name ?? '',
                                              ),
                                              sender?.name.isNotEmpty ?? false)
                                          .appendIf(
                                              AdaptiveCard(
                                                child: 'Date',
                                                regular: true,
                                                after: DateFormat.yMMMMEEEEd(Share.settings.appSettings.localeCode)
                                                    .format(date ?? timeFrom),
                                              ),
                                              date != null)
                                          .appendIf(
                                              AdaptiveCard(child: 'Classroom', regular: true, after: classroom?.name ?? ''),
                                              classroom?.name.isNotEmpty ?? false)
                                          .appendIf(
                                              AdaptiveCard(
                                                child: 'Start time',
                                                regular: true,
                                                after: DateFormat.Hm(Share.settings.appSettings.localeCode).format(timeFrom),
                                              ),
                                              timeFrom.hour != 0)
                                          .appendIf(
                                              AdaptiveCard(
                                                child: 'End time',
                                                regular: true,
                                                after: DateFormat.Hm(Share.settings.appSettings.localeCode)
                                                    .format(timeTo ?? timeFrom),
                                              ),
                                              timeTo != null && timeTo?.hour != 0))
                                ]))
                                .toList()))),
        margin: EdgeInsets.only(left: 15, top: 5, bottom: 5, right: 20),
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
                                      // Unread badge
                                      UnreadDot(
                                          unseen: () => unseen,
                                          markAsSeen: markAsSeen,
                                          margin: EdgeInsets.only(top: 5, right: 6)),
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
                                            maxLines: 1,
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
                                                maxLines: 1,
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
                                                      maxLines: 1,
                                                      "${DateFormat.Hm(Share.settings.appSettings.localeCode).format(timeFrom)} - ${DateFormat.Hm(Share.settings.appSettings.localeCode).format(timeTo ?? DateTime.now())}",
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontStyle: markModified ? FontStyle.italic : null,
                                                          decoration: markRemoved ? TextDecoration.lineThrough : null),
                                                    )
                                                  : Text(
                                                      maxLines: 1,
                                                      (timeFrom.month == timeTo?.month && timeFrom.day == timeTo?.day)
                                                          ? DateFormat.MMMd(Share.settings.appSettings.localeCode)
                                                              .format(timeTo ?? DateTime.now())
                                                          : (timeFrom.month == timeTo?.month)
                                                              ? "${DateFormat.d(Share.settings.appSettings.localeCode).format(timeFrom)} - ${DateFormat.MMMd(Share.settings.appSettings.localeCode).format(timeTo ?? DateTime.now())}"
                                                              : "${DateFormat.MMMd(Share.settings.appSettings.localeCode).format(timeFrom)} - ${DateFormat.MMMd(Share.settings.appSettings.localeCode).format(timeTo ?? DateTime.now())}",
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
                                              maxLines: 1,
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
                    ]))));

    return animation == null ? body : Hero(tag: tag, child: body);
  }
}

extension LessonWidgetExtension on TimetableLesson {
  Widget asLessonWidget(
      BuildContext context, DateTime? selectedDate, TimetableDay? selectedDay, void Function(VoidCallback fn) setState,
      {bool markRemoved = false, bool markModified = false, Function()? onTap}) {
    var lessonCallButtonString = switch (Share.session.settings.lessonCallType) {
      LessonCallTypes.countFromEnd => 'last ${Share.session.settings.lessonCallTime} min',
      LessonCallTypes.countFromStart => 'first ${Share.session.settings.lessonCallTime} min',
      LessonCallTypes.halfLesson => 'half the lesson',
      LessonCallTypes.wholeLesson => 'whole lesson'
    };

    var lessonCallMessageString = switch (Share.session.settings.lessonCallType) {
      LessonCallTypes.countFromEnd => 'ostatnich ${Share.session.settings.lessonCallTime} minut lekcji',
      LessonCallTypes.countFromStart => 'pierwszych ${Share.session.settings.lessonCallTime} minut lekcji',
      LessonCallTypes.halfLesson => 'połowy',
      LessonCallTypes.wholeLesson => 'całej'
    };

    return AdaptiveMenuButton(
        itemBuilder: (context) => [
              AdaptiveMenuItem(
                onTap: () {
                  sharing.Share.share(
                      'There\'s ${subject?.name ?? "a lesson"} on ${DateFormat("EEEE, MMM d, y").format(date)} with ${teacher?.name ?? "a teacher"}');
                  Navigator.of(context, rootNavigator: true).pop();
                },
                icon: CupertinoIcons.share,
                title: 'Share',
              ),
              AdaptiveMenuItem(
                onTap: () {
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
                icon: CupertinoIcons.calendar,
                title: 'Add to calendar',
              ),
              AdaptiveMenuItem(
                onTap: () {
                  try {
                    showMaterialModalBottomSheet(
                        context: context,
                        builder: (context) => EventComposePage(
                              date: date,
                              startTime: timeFrom,
                              endTime: timeTo,
                              classroom: classroom?.name,
                              lessonNumber: lessonNo,
                            )).then((value) => setState(() {}));
                  } catch (ex) {
                    // ignored
                  }
                  Navigator.of(context, rootNavigator: true).pop();
                },
                icon: CupertinoIcons.add,
                title: 'Create event',
              ),
              AdaptiveMenuItem(
                icon: CupertinoIcons.timer,
                title: 'Call $lessonCallButtonString',
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  showMaterialModalBottomSheet(
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
              AdaptiveMenuItem(
                icon: CupertinoIcons.chat_bubble_2,
                title: 'Inquiry',
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  showMaterialModalBottomSheet(
                      context: context,
                      builder: (context) => MessageComposePage(
                          receivers: teacher != null ? [teacher!] : [],
                          subject: 'Pytanie o lekcję w dniu ${DateFormat("y.M.d").format(date)}, L$lessonNo',
                          signature:
                              '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                },
              ),
            ],
        child: lessonBody(context, selectedDate, selectedDay,
            animation: null, markRemoved: markRemoved, markModified: markModified, onTap: onTap));
  }

  Widget lessonBody(BuildContext context, DateTime? selectedDate, TimetableDay? selectedDay,
      {Animation<double>? animation,
      bool markRemoved = false,
      bool markModified = false,
      bool useOnTap = false,
      Function()? onTap}) {
    var events = Share.session.events
        .where((y) => y.date == selectedDate)
        .where((y) => (y.lessonNo ?? -1) == lessonNo)
        .select((y, index) => TableRow(children: [
              Container(
                  margin: EdgeInsets.only(top: 20, left: 15, right: 15), child: y.eventBody(true, selectedDay, context))
            ]))
        .toList();

    var tag = Uuid().v4();
    var body = GestureDetector(
        onTap: (useOnTap && onTap != null)
            ? onTap
            : (animation == null || animation.value >= CupertinoContextMenu.animationOpensAt)
                ? null
                : () => showMaterialModalBottomSheet(
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
                                  CardContainer(
                                      additionalDividerMargin: 5,
                                      children: <Widget>[]
                                          .appendIf(
                                              AdaptiveCard(
                                                  child: Row(
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
                                              AdaptiveCard(
                                                  child: Row(
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
                                              AdaptiveCard(
                                                  child: Row(
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
                                              AdaptiveCard(
                                                  child: Row(
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
                                              AdaptiveCard(
                                                  child: Row(
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
                                              AdaptiveCard(
                                                  child: Row(
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
                                              AdaptiveCard(
                                                  child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(isCanceled ? 'Moved to' : 'Moved from'),
                                                  Flexible(
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Text(
                                                                  '${DateFormat.yMd(Share.settings.appSettings.localeCode).format(substitutionDetails?.originalDate ?? DateTime.now().asDate())}${substitutionDetails?.originalLessonNo != null ? ', L${substitutionDetails?.originalLessonNo.toString()}' : ''}',
                                                                  maxLines: 3,
                                                                  textAlign: TextAlign.end))))
                                                ],
                                              )),
                                              isMovedLesson)
                                          // Substitution details - cancelled
                                          .appendIf(
                                              AdaptiveCard(
                                                  child: Row(
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
                                  Share.session.events
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
                                        UnreadDot(
                                            unseen: () => unseen,
                                            markAsSeen: markAsSeen,
                                            margin: EdgeInsets.only(top: 5, right: 6)),
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
