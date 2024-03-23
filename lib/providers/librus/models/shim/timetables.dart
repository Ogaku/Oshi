import 'package:json_annotation/json_annotation.dart';

part 'timetables.g.dart';

@JsonSerializable()
class Timetables {
  Timetables({
    required this.timetable,
  });

  @JsonKey(name: 'Timetable', defaultValue: {})
  final Map<String, List<List<TimetableLesson>?>> timetable;

  factory Timetables.fromJson(Map<String, dynamic> json) => _$TimetablesFromJson(json);

  Map<String, dynamic> toJson() => _$TimetablesToJson(this);
}

@JsonSerializable()
class TimetableLesson {
  TimetableLesson({
    required this.lesson,
    required this.classroom,
    required this.dateFrom,
    required this.dateTo,
    required this.lessonNo,
    required this.subject,
    required this.teacher,
    required this.isSubstitutionClass,
    required this.isCanceled,
    required this.hourFrom,
    required this.hourTo,
    required this.timetableLessonClass,
    this.orgClassroom,
    this.orgDate,
    this.orgLessonNo,
    this.orgLesson,
    this.orgSubject,
    this.orgTeacher,
    this.orgHourFrom,
    this.orgHourTo,
    this.newClassroom,
    this.newDate,
    this.newLessonNo,
    this.newLesson,
    this.newSubject,
    this.newTeacher,
    this.newHourFrom,
    this.newHourTo,
    this.substitutionClassUrl,
    this.virtualClass,
    this.virtualClassName,
  });

  @JsonKey(name: 'Lesson', defaultValue: null)
  final Link? lesson;

  @JsonKey(name: 'Classroom', defaultValue: null)
  final Link? classroom;

  @JsonKey(name: 'DateFrom', defaultValue: null)
  final DateTime? dateFrom;

  @JsonKey(name: 'DateTo', defaultValue: null)
  final DateTime? dateTo;

  @JsonKey(name: 'LessonNo', defaultValue: '')
  final String lessonNo;

  @JsonKey(name: 'Subject', defaultValue: null)
  final Subject? subject;

  @JsonKey(name: 'Teacher', defaultValue: null)
  final Teacher? teacher;

  @JsonKey(name: 'IsSubstitutionClass', defaultValue: false)
  final bool isSubstitutionClass;

  @JsonKey(name: 'IsCanceled', defaultValue: false)
  final bool isCanceled;

  @JsonKey(name: 'HourFrom', defaultValue: '00:00')
  final String hourFrom;

  @JsonKey(name: 'HourTo', defaultValue: '00:00')
  final String hourTo;

  @JsonKey(name: 'VirtualClass', defaultValue: null)
  final Class? virtualClass;

  @JsonKey(name: 'VirtualClassName', defaultValue: null)
  final String? virtualClassName;

  @JsonKey(name: 'Class', defaultValue: null)
  final Class? timetableLessonClass;

  @JsonKey(name: 'OrgClassroom', defaultValue: null)
  final Link? orgClassroom;

  @JsonKey(name: 'OrgDate', defaultValue: null)
  final DateTime? orgDate;

  @JsonKey(name: 'OrgLessonNo', defaultValue: null)
  final String? orgLessonNo;

  @JsonKey(name: 'OrgLesson', defaultValue: null)
  final Link? orgLesson;

  @JsonKey(name: 'OrgSubject', defaultValue: null)
  final Link? orgSubject;

  @JsonKey(name: 'OrgTeacher', defaultValue: null)
  final Link? orgTeacher;

  @JsonKey(name: 'OrgHourFrom', defaultValue: null)
  final String? orgHourFrom;

  @JsonKey(name: 'OrgHourTo', defaultValue: null)
  final String? orgHourTo;

  @JsonKey(name: 'NewClassroom', defaultValue: null)
  final Link? newClassroom;

  @JsonKey(name: 'NewDate', defaultValue: null)
  final DateTime? newDate;

  @JsonKey(name: 'NewLessonNo', defaultValue: null)
  final String? newLessonNo;

  @JsonKey(name: 'NewLesson', defaultValue: null)
  final Link? newLesson;

  @JsonKey(name: 'NewSubject', defaultValue: null)
  final Link? newSubject;

  @JsonKey(name: 'NewTeacher', defaultValue: null)
  final Link? newTeacher;

  @JsonKey(name: 'NewHourFrom', defaultValue: null)
  final String? newHourFrom;

  @JsonKey(name: 'NewHourTo', defaultValue: null)
  final String? newHourTo;

  @JsonKey(name: 'SubstitutionClassUrl', defaultValue: null)
  final String? substitutionClassUrl;

  factory TimetableLesson.fromJson(Map<String, dynamic> json) => _$TimetableLessonFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableLessonToJson(this);
}

@JsonSerializable()
class Link {
  Link({
    this.id,
    this.url,
  });

  @JsonKey(name: 'Id', defaultValue: '')
  final String? id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String? url;

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

  Map<String, dynamic> toJson() => _$LinkToJson(this);
}

@JsonSerializable()
class Class {
  Class({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory Class.fromJson(Map<String, dynamic> json) => _$ClassFromJson(json);

  Map<String, dynamic> toJson() => _$ClassToJson(this);
}

@JsonSerializable()
class Subject {
  Subject({
    required this.id,
    required this.name,
    required this.short,
    required this.url,
  });

  @JsonKey(name: 'Id', defaultValue: '')
  final String id;

  @JsonKey(name: 'Name', defaultValue: '')
  final String name;

  @JsonKey(name: 'Short', defaultValue: '')
  final String short;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}

@JsonSerializable()
class Teacher {
  Teacher({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.url,
  });

  @JsonKey(name: 'Id', defaultValue: '')
  final String id;

  @JsonKey(name: 'FirstName', defaultValue: '')
  final String firstName;

  @JsonKey(name: 'LastName', defaultValue: '')
  final String lastName;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory Teacher.fromJson(Map<String, dynamic> json) => _$TeacherFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherToJson(this);
}
