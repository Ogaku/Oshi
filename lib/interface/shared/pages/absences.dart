// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/interface/components/shim/elements/attendance.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/shared/views/message_compose.dart';

// Boiler: returned to the app tab builder
StatefulWidget get absencesPage => AbsencesPage();

class AbsencesPage extends StatefulWidget {
  const AbsencesPage({super.key});

  @override
  State<AbsencesPage> createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  SegmentController segmentController = SegmentController(segment: AbsencesPageSegments.date);

  bool showInbox = true;
  bool isWorking = false;

  @override
  void dispose() {
    Share.refreshAll.unsubscribe(refresh);
    super.dispose();
  }

  void refresh(args) {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Re-subscribe to all events
    Share.refreshAll.unsubscribe(refresh);
    Share.refreshAll.subscribe(refresh);

    // Group by date, I know IT'S A DAMN STRING, but we're saving on custom controls
    var attendancesToDisplayByDate = Share.session.data.student.attendances
            ?.orderByDescending((x) => x.date)
            .groupBy((x) => DateFormat.yMMMMEEEEd(Share.settings.appSettings.localeCode).format(x.date))
            .toList() ??
        [];

    // Group by subjects, or at least what we can access right now
    var attendancesToDisplayByLesson = Share.session.data.student.attendances
            ?.orderByDescending((x) => x.date)
            .groupBy((x) => x.lesson.subject?.name ?? 'Unknown subject')
            .select((x, index) => Grouping(
                x.elements,
                "${x.key}\n${(100 * x.elements.where((y) => y.type == AttendanceType.present).count() / x.elements.count()).round()}%",
                Random().nextInt(100)))
            .orderBy((x) => x.key)
            .toList() ??
        [];

    // Group by type, try to show absences first
    var attendancesToDisplayByType = Share.session.data.student.attendances
            ?.orderByDescending((x) => x.date)
            .groupBy((x) => x.type.asStringLong())
            .orderBy((x) => x.key)
            .toList() ??
        [];

    // This is gonna be a veeery long list, as there are no expanders in cupertino
    var attendances = (switch (segmentController.segment) {
      AbsencesPageSegments.lesson => attendancesToDisplayByLesson,
      AbsencesPageSegments.type => attendancesToDisplayByType,
      AbsencesPageSegments.date || _ => attendancesToDisplayByDate
    });

    return DataPageBase.adaptive(
        pageFlags: [
          DataPageType.segmented,
          DataPageType.refreshable,
          DataPageType.boxedPage,
          DataPageType.segmentedSticky,
        ].flag,
        setState: setState,
        segments: {
          AbsencesPageSegments.date: '/ByDate'.localized,
          AbsencesPageSegments.lesson: '/ByLesson'.localized,
          AbsencesPageSegments.type: '/ByType'.localized
        },
        title: '/Page/Absences/Attendance'.localized,
        segmentController: segmentController,
        trailing: isWorking
            ? Container(
                margin: EdgeInsets.only(right: 5, top: 5),
                child: Share.settings.appSettings.useCupertino
                    ? CupertinoActivityIndicator(radius: 12)
                    : SizedBox(height: 20, width: 20, child: CircularProgressIndicator()))
            : AdaptiveMenuButton(
                itemBuilder: (context) => [
                  AdaptiveMenuItem(
                    title: 'Mark as read',
                    icon: CupertinoIcons.checkmark_circle,
                    onTap: () => Share.session.unreadChanges.markAsRead(attendaceOnly: true),
                  ),
                  AdaptiveMenuItem(
                    title: 'Excuse all',
                    icon: CupertinoIcons.doc_on_clipboard,
                    onTap: () {
                      if (Share.session.data.student.attendances?.isEmpty ?? true) return;
                      showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => MessageComposePage(
                              receivers: [Share.session.data.student.mainClass.classTutor],
                              subject: 'Usprawiedliwienie',
                              message:
                                  'Dzień dobry,\n\nProszę o usprawiedliwienie moich nieobecności w dniach:\n${Share.session.data.student.attendances!.where((x) => x.type == AttendanceType.absent).groupBy((x) => x.date).select((x, index) => ' - ${DateFormat("y.M.dd").format(x.key)} (${x.count > 1 ? '${x.orderBy((x) => x.lessonNo).first.lessonNo} - ${x.orderBy((x) => x.lessonNo).last.lessonNo} godzina lekcyjna' : '${x.first.lessonNo} godzina lekcyjna'}) \n').join()}',
                              signature:
                                  'Dziękuję,\n\nZ poważaniem,\n${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                    },
                  ),
                ],
              ),
        children: attendances
            .select(
              (x, _) => CardContainer(
                regularOverride: true,
                filled: false,
                capitalize: false,
                header: Share.settings.appSettings.useCupertino
                    ? (x.key.contains('\n')
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(child: Text(x.key.split('\n').first, maxLines: 1, overflow: TextOverflow.ellipsis)),
                              Container(
                                  margin: EdgeInsets.only(left: 3),
                                  child: Text(x.key.split('\n').last,
                                      style: TextStyle(
                                          color: CupertinoColors.inactiveGray, fontWeight: FontWeight.w400, fontSize: 16)))
                            ],
                          )
                        : x.key)
                    : (x.key.contains('\n') ? x.key.replaceAll('\n', ' ー ') : x.key),
                additionalDividerMargin: 5,
                children: x.isEmpty
                    // No messages to display
                    ? []
                    // Bindable messages layout
                    : x
                        .select((x, index) => Share.settings.appSettings.useCupertino
                            ? AdaptiveCard(child: x.asAttendanceWidget(context))
                            : x.asAttendanceWidget(context))
                        .toList(),
              ),
            )
            .cast<Widget>()
            .appendIfEmpty(AdaptiveCard(
              centered: true,
              secondary: true,
              child: '/Page/Absences/No'.localized,
            ))
            .toList());
  }
}

enum AbsencesPageSegments { date, lesson, type }
