import 'package:json_annotation/json_annotation.dart';

part 'timetables.g.dart';

@JsonSerializable()
class Timetables {
  Timetables({
    required this.timetable,
  });

  @JsonKey(name: 'Timetable')
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

  @JsonKey(name: 'Lesson')
  final Link? lesson;

  @JsonKey(name: 'Classroom')
  final Link? classroom;

  @JsonKey(name: 'DateFrom')
  final DateTime? dateFrom;

  @JsonKey(name: 'DateTo')
  final DateTime? dateTo;

  @JsonKey(name: 'LessonNo')
  final String lessonNo;

  @JsonKey(name: 'Subject')
  final Subject? subject;

  @JsonKey(name: 'Teacher')
  final Teacher? teacher;

  @JsonKey(name: 'IsSubstitutionClass')
  final bool isSubstitutionClass;

  @JsonKey(name: 'IsCanceled')
  final bool isCanceled;

  @JsonKey(name: 'HourFrom')
  final String hourFrom;

  @JsonKey(name: 'HourTo')
  final String hourTo;

  @JsonKey(name: 'VirtualClass')
  final Class? virtualClass;

  @JsonKey(name: 'VirtualClassName')
  final String? virtualClassName;

  @JsonKey(name: 'Class')
  final Class? timetableLessonClass;

  @JsonKey(name: 'OrgClassroom')
  final Link? orgClassroom;

  @JsonKey(name: 'OrgDate')
  final DateTime? orgDate;

  @JsonKey(name: 'OrgLessonNo')
  final String? orgLessonNo;

  @JsonKey(name: 'OrgLesson')
  final Link? orgLesson;

  @JsonKey(name: 'OrgSubject')
  final Link? orgSubject;

  @JsonKey(name: 'OrgTeacher')
  final Link? orgTeacher;

  @JsonKey(name: 'OrgHourFrom')
  final String? orgHourFrom;

  @JsonKey(name: 'OrgHourTo')
  final String? orgHourTo;

  @JsonKey(name: 'NewClassroom')
  final Link? newClassroom;

  @JsonKey(name: 'NewDate')
  final DateTime? newDate;

  @JsonKey(name: 'NewLessonNo')
  final String? newLessonNo;

  @JsonKey(name: 'NewLesson')
  final Link? newLesson;

  @JsonKey(name: 'NewSubject')
  final Link? newSubject;

  @JsonKey(name: 'NewTeacher')
  final Link? newTeacher;

  @JsonKey(name: 'NewHourFrom')
  final String? newHourFrom;

  @JsonKey(name: 'NewHourTo')
  final String? newHourTo;

  @JsonKey(name: 'SubstitutionClassUrl')
  final String? substitutionClassUrl;

  factory TimetableLesson.fromJson(Map<String, dynamic> json) => _$TimetableLessonFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableLessonToJson(this);
}

@JsonSerializable()
class Link {
  Link({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final String id;

  @JsonKey(name: 'Url')
  final String url;

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

  Map<String, dynamic> toJson() => _$LinkToJson(this);
}

@JsonSerializable()
class Class {
  Class({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
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

  @JsonKey(name: 'Id')
  final String id;

  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'Short')
  final String short;

  @JsonKey(name: 'Url')
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

  @JsonKey(name: 'Id')
  final String id;

  @JsonKey(name: 'FirstName')
  final String firstName;

  @JsonKey(name: 'LastName')
  final String lastName;

  @JsonKey(name: 'Url')
  final String url;

  factory Teacher.fromJson(Map<String, dynamic> json) => _$TeacherFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherToJson(this);
}
