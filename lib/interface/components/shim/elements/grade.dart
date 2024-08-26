// ignore_for_file: prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:oshi/models/data/grade.dart';

import 'package:oshi/share/share.dart';

import 'package:oshi/interface/components/cupertino/elements/grade.dart' as cupertino;
import 'package:oshi/interface/components/material/elements/grade.dart' as material;

extension GradeBodyExtension on Grade {
  Widget asGrade(BuildContext context, void Function(VoidCallback fn) setState,
          {bool markRemoved = false, bool markModified = false, Function()? onTap, Grade? corrected}) =>
      Share.settings.appSettings.useCupertino
          ? cupertino.GradeBodyExtension(this).asGrade(context, setState,
              markRemoved: markRemoved, markModified: markModified, onTap: onTap, corrected: corrected)
          : material.GradeBodyExtension(this).asGrade(context, setState,
              markRemoved: markRemoved, markModified: markModified, onTap: onTap, corrected: corrected);

  Widget gradeBody(BuildContext context,
          {Animation<double>? animation,
          bool markRemoved = false,
          bool markModified = false,
          bool useOnTap = false,
          Function()? onTap,
          Grade? corrected}) =>
      Share.settings.appSettings.useCupertino
          ? cupertino.GradeBodyExtension(this).gradeBody(context,
              animation: animation,
              markRemoved: markRemoved,
              markModified: markModified,
              useOnTap: useOnTap,
              onTap: onTap,
              corrected: corrected)
          : material.GradeBodyExtension(this).gradeBody(context,
              animation: animation,
              markRemoved: markRemoved,
              markModified: markModified,
              useOnTap: useOnTap,
              onTap: onTap,
              corrected: corrected);
}
