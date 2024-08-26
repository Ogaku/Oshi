// ignore_for_file: prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/share/share.dart';

import 'package:oshi/interface/components/cupertino/elements/attendance.dart' as cupertino;
import 'package:oshi/interface/components/material/elements/attendance.dart' as material;

extension AttendanceTypeExtension on AttendanceType {
  String asString() => Share.settings.appSettings.useCupertino
      ? cupertino.AttendanceTypeExtension(this).asString()
      : material.AttendanceTypeExtension(this).asString();

  String asStringLong() => Share.settings.appSettings.useCupertino
      ? cupertino.AttendanceTypeExtension(this).asStringLong()
      : material.AttendanceTypeExtension(this).asStringLong();

  String asPrep() => Share.settings.appSettings.useCupertino
      ? cupertino.AttendanceTypeExtension(this).asPrep()
      : material.AttendanceTypeExtension(this).asPrep();

  Color asColor() => Share.settings.appSettings.useCupertino
      ? cupertino.AttendanceTypeExtension(this).asColor()
      : material.AttendanceTypeExtension(this).asColor();
}

extension LessonWidgetExtension on Attendance {
  Widget asAttendanceWidget(BuildContext context,
          {bool markRemoved = false, bool markModified = false, Function()? onTap}) =>
      Share.settings.appSettings.useCupertino
          ? cupertino.LessonWidgetExtension(this)
              .asAttendanceWidget(context, markRemoved: markRemoved, markModified: markModified, onTap: onTap)
          : material.LessonWidgetExtension(this)
              .asAttendanceWidget(context, markRemoved: markRemoved, markModified: markModified, onTap: onTap);

  Widget attendanceBody(BuildContext context,
          {Animation<double>? animation,
          bool markRemoved = false,
          bool markModified = false,
          bool useOnTap = false,
          Function()? onTap}) =>
      Share.settings.appSettings.useCupertino
          ? cupertino.LessonWidgetExtension(this).attendanceBody(context,
              animation: animation, markRemoved: markRemoved, markModified: markModified, useOnTap: useOnTap, onTap: onTap)
          : material.LessonWidgetExtension(this).attendanceBody(context,
              animation: animation, markRemoved: markRemoved, markModified: markModified, useOnTap: useOnTap, onTap: onTap);
}
