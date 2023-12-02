// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grades.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Grades _$GradesFromJson(Map<String, dynamic> json) => Grades(
      grades: (json['Grades'] as List<dynamic>?)
          ?.map((e) => Grade.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GradesToJson(Grades instance) => <String, dynamic>{
      'Grades': instance.grades,
    };

Grade _$GradeFromJson(Map<String, dynamic> json) => Grade(
      id: json['Id'] as int,
      lesson: json['Lesson'] == null
          ? null
          : Link.fromJson(json['Lesson'] as Map<String, dynamic>),
      subject: json['Subject'] == null
          ? null
          : Link.fromJson(json['Subject'] as Map<String, dynamic>),
      student: json['Student'] == null
          ? null
          : Link.fromJson(json['Student'] as Map<String, dynamic>),
      category: json['Category'] == null
          ? null
          : Link.fromJson(json['Category'] as Map<String, dynamic>),
      addedBy: json['AddedBy'] == null
          ? null
          : Link.fromJson(json['AddedBy'] as Map<String, dynamic>),
      grade: json['Grade'] as String,
      date:
          json['Date'] == null ? null : DateTime.parse(json['Date'] as String),
      addDate: json['AddDate'] == null
          ? null
          : DateTime.parse(json['AddDate'] as String),
      semester: json['Semester'] as int,
      isConstituent: json['IsConstituent'] as bool,
      isSemester: json['IsSemester'] as bool,
      isSemesterProposition: json['IsSemesterProposition'] as bool,
      isFinal: json['IsFinal'] as bool,
      isFinalProposition: json['IsFinalProposition'] as bool,
      comments: (json['Comments'] as List<dynamic>?)
          ?.map((e) => Link.fromJson(e as Map<String, dynamic>))
          .toList(),
      resit: json['Resit'],
      improvement: json['Improvement'],
    );

Map<String, dynamic> _$GradeToJson(Grade instance) {
  final val = <String, dynamic>{
    'Id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('Lesson', instance.lesson);
  writeNotNull('Subject', instance.subject);
  writeNotNull('Student', instance.student);
  writeNotNull('Category', instance.category);
  writeNotNull('AddedBy', instance.addedBy);
  val['Grade'] = instance.grade;
  writeNotNull('Date', instance.date?.toIso8601String());
  writeNotNull('AddDate', instance.addDate?.toIso8601String());
  val['Semester'] = instance.semester;
  val['IsConstituent'] = instance.isConstituent;
  val['IsSemester'] = instance.isSemester;
  val['IsSemesterProposition'] = instance.isSemesterProposition;
  val['IsFinal'] = instance.isFinal;
  val['IsFinalProposition'] = instance.isFinalProposition;
  writeNotNull('Comments', instance.comments);
  writeNotNull('Resit', instance.resit);
  writeNotNull('Improvement', instance.improvement);
  return val;
}

Link _$LinkFromJson(Map<String, dynamic> json) => Link(
      id: json['Id'] as int,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$LinkToJson(Link instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
