// ignore_for_file: prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/share/share.dart';

import 'package:oshi/interface/components/cupertino/elements/compact.dart' as cupertino;
import 'package:oshi/interface/components/material/elements/compact.dart' as material;

extension EventBodyExtension on List<Event> {
  List<Widget> asCompactEventList(BuildContext context) => Share.settings.appSettings.useCupertino
      ? cupertino.EventBodyExtension(this).asCompactEventList(context)
      : material.EventBodyExtension(this).asCompactEventList(context);

  List<Widget> asCompactHomeworkList(BuildContext context) => Share.settings.appSettings.useCupertino
      ? cupertino.EventBodyExtension(this).asCompactHomeworkList(context)
      : material.EventBodyExtension(this).asCompactHomeworkList(context);
}

extension GradeBodyExtension on List<({List<Grade> grades, Lesson lesson})> {
  List<Widget> asCompactGradeList(BuildContext context) => Share.settings.appSettings.useCupertino
      ? cupertino.GradeBodyExtension(this).asCompactGradeList(context)
      : material.GradeBodyExtension(this).asCompactGradeList(context);
}
