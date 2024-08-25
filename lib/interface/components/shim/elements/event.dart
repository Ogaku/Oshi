// ignore_for_file: prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:oshi/interface/shared/views/events_timeline.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/data/timetables.dart';
import 'package:oshi/share/share.dart';

import 'package:oshi/interface/components/cupertino/elements/event.dart' as cupertino;
import 'package:oshi/interface/components/material/elements/event.dart' as material;

extension TimelineWidgetsExtension on Iterable<AgendaEvent> {
  List<Widget> asEventWidgets(
          TimetableDay? day, String searchQuery, String placeholder, void Function(VoidCallback fn) setState) =>
      Share.settings.appSettings.useCupertino
          ? cupertino.TimelineWidgetsExtension(this).asEventWidgets(day, searchQuery, placeholder, setState)
          : material.TimelineWidgetsExtension(this).asEventWidgets(day, searchQuery, placeholder, setState);
}

extension EventColors on Event {
  Color asColor() =>
      Share.settings.appSettings.useCupertino ? cupertino.EventColors(this).asColor() : material.EventColors(this).asColor();
  double get cardHeight => Share.settings.appSettings.useCupertino
      ? cupertino.EventColors(this).cardHeight
      : material.EventColors(this).cardHeight;
}

extension EventWidgetsExtension on Iterable<Event> {
  List<Widget> asEventWidgets(
          TimetableDay? day, String searchQuery, String placeholder, void Function(VoidCallback fn) setState) =>
      Share.settings.appSettings.useCupertino
          ? cupertino.EventWidgetsExtension(this).asEventWidgets(day, searchQuery, placeholder, setState)
          : material.EventWidgetsExtension(this).asEventWidgets(day, searchQuery, placeholder, setState);
}

extension EventWidgetExtension on Event {
  Widget asEventWidget(BuildContext context, bool isNotEmpty, TimetableDay? day, void Function(VoidCallback fn) setState,
          {bool markRemoved = false, bool markModified = false, Function()? onTap}) =>
      Share.settings.appSettings.useCupertino
          ? cupertino.EventWidgetExtension(this).asEventWidget(context, isNotEmpty, day, setState,
              markRemoved: markRemoved, markModified: markModified, onTap: onTap)
          : material.EventWidgetExtension(this).asEventWidget(context, isNotEmpty, day, setState,
              markRemoved: markRemoved, markModified: markModified, onTap: onTap);

  Widget eventBody(bool isNotEmpty, TimetableDay? day, BuildContext context,
          {Animation<double>? animation,
          bool markRemoved = false,
          bool markModified = false,
          bool useOnTap = false,
          Function()? onTap}) =>
      Share.settings.appSettings.useCupertino
          ? cupertino.EventWidgetExtension(this).eventBody(isNotEmpty, day, context,
              animation: animation, markRemoved: markRemoved, markModified: markModified, useOnTap: useOnTap, onTap: onTap)
          : material.EventWidgetExtension(this).eventBody(isNotEmpty, day, context,
              animation: animation, markRemoved: markRemoved, markModified: markModified, useOnTap: useOnTap, onTap: onTap);
}

extension LessonWidgetExtension on TimetableLesson {
  Widget asLessonWidget(
          BuildContext context, DateTime? selectedDate, TimetableDay? selectedDay, void Function(VoidCallback fn) setState,
          {bool markRemoved = false, bool markModified = false, Function()? onTap}) =>
      Share.settings.appSettings.useCupertino
          ? cupertino.LessonWidgetExtension(this).asLessonWidget(context, selectedDate, selectedDay, setState,
              markRemoved: markRemoved, markModified: markModified, onTap: onTap)
          : material.LessonWidgetExtension(this).asLessonWidget(context, selectedDate, selectedDay, setState,
              markRemoved: markRemoved, markModified: markModified, onTap: onTap);

  Widget lessonBody(BuildContext context, DateTime? selectedDate, TimetableDay? selectedDay,
          {Animation<double>? animation,
          bool markRemoved = false,
          bool markModified = false,
          bool useOnTap = false,
          Function()? onTap}) =>
      Share.settings.appSettings.useCupertino
          ? cupertino.LessonWidgetExtension(this).lessonBody(context, selectedDate, selectedDay,
              animation: animation, markRemoved: markRemoved, markModified: markModified, useOnTap: useOnTap, onTap: onTap)
          : material.LessonWidgetExtension(this).lessonBody(context, selectedDate, selectedDay,
              animation: animation, markRemoved: markRemoved, markModified: markModified, useOnTap: useOnTap, onTap: onTap);
}
