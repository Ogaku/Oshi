// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetables.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timetables _$TimetablesFromJson(Map<String, dynamic> json) => Timetables(
      timetable: (json['Timetable'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => (e as List<dynamic>?)
                    ?.map((e) =>
                        TimetableLesson.fromJson(e as Map<String, dynamic>))
                    .toList())
                .toList()),
      ),
    );

Map<String, dynamic> _$TimetablesToJson(Timetables instance) =>
    <String, dynamic>{
      'Timetable': instance.timetable,
    };

TimetableLesson _$TimetableLessonFromJson(Map<String, dynamic> json) =>
    TimetableLesson(
      lesson: json['Lesson'] == null
          ? null
          : Link.fromJson(json['Lesson'] as Map<String, dynamic>),
      classroom: json['Classroom'] == null
          ? null
          : Link.fromJson(json['Classroom'] as Map<String, dynamic>),
      dateFrom: json['DateFrom'] == null
          ? null
          : DateTime.parse(json['DateFrom'] as String),
      dateTo: json['DateTo'] == null
          ? null
          : DateTime.parse(json['DateTo'] as String),
      lessonNo: json['LessonNo'] as String,
      subject: json['Subject'] == null
          ? null
          : Subject.fromJson(json['Subject'] as Map<String, dynamic>),
      teacher: json['Teacher'] == null
          ? null
          : Teacher.fromJson(json['Teacher'] as Map<String, dynamic>),
      isSubstitutionClass: json['IsSubstitutionClass'] as bool,
      isCanceled: json['IsCanceled'] as bool,
      hourFrom: json['HourFrom'] as String,
      hourTo: json['HourTo'] as String,
      timetableLessonClass: json['Class'] == null
          ? null
          : Class.fromJson(json['Class'] as Map<String, dynamic>),
      orgClassroom: json['OrgClassroom'] == null
          ? null
          : Link.fromJson(json['OrgClassroom'] as Map<String, dynamic>),
      orgDate: json['OrgDate'] == null
          ? null
          : DateTime.parse(json['OrgDate'] as String),
      orgLessonNo: json['OrgLessonNo'] as String?,
      orgLesson: json['OrgLesson'] == null
          ? null
          : Link.fromJson(json['OrgLesson'] as Map<String, dynamic>),
      orgSubject: json['OrgSubject'] == null
          ? null
          : Link.fromJson(json['OrgSubject'] as Map<String, dynamic>),
      orgTeacher: json['OrgTeacher'] == null
          ? null
          : Link.fromJson(json['OrgTeacher'] as Map<String, dynamic>),
      orgHourFrom: json['OrgHourFrom'] as String?,
      orgHourTo: json['OrgHourTo'] as String?,
      newClassroom: json['NewClassroom'] == null
          ? null
          : Link.fromJson(json['NewClassroom'] as Map<String, dynamic>),
      newDate: json['NewDate'] == null
          ? null
          : DateTime.parse(json['NewDate'] as String),
      newLessonNo: json['NewLessonNo'] as String?,
      newLesson: json['NewLesson'] == null
          ? null
          : Link.fromJson(json['NewLesson'] as Map<String, dynamic>),
      newSubject: json['NewSubject'] == null
          ? null
          : Link.fromJson(json['NewSubject'] as Map<String, dynamic>),
      newTeacher: json['NewTeacher'] == null
          ? null
          : Link.fromJson(json['NewTeacher'] as Map<String, dynamic>),
      newHourFrom: json['NewHourFrom'] as String?,
      newHourTo: json['NewHourTo'] as String?,
      substitutionClassUrl: json['SubstitutionClassUrl'] as String?,
      virtualClass: json['VirtualClass'] == null
          ? null
          : Class.fromJson(json['VirtualClass'] as Map<String, dynamic>),
      virtualClassName: json['VirtualClassName'] as String?,
    );

Map<String, dynamic> _$TimetableLessonToJson(TimetableLesson instance) =>
    <String, dynamic>{
      'Lesson': instance.lesson,
      'Classroom': instance.classroom,
      'DateFrom': instance.dateFrom?.toIso8601String(),
      'DateTo': instance.dateTo?.toIso8601String(),
      'LessonNo': instance.lessonNo,
      'Subject': instance.subject,
      'Teacher': instance.teacher,
      'IsSubstitutionClass': instance.isSubstitutionClass,
      'IsCanceled': instance.isCanceled,
      'HourFrom': instance.hourFrom,
      'HourTo': instance.hourTo,
      'VirtualClass': instance.virtualClass,
      'VirtualClassName': instance.virtualClassName,
      'Class': instance.timetableLessonClass,
      'OrgClassroom': instance.orgClassroom,
      'OrgDate': instance.orgDate?.toIso8601String(),
      'OrgLessonNo': instance.orgLessonNo,
      'OrgLesson': instance.orgLesson,
      'OrgSubject': instance.orgSubject,
      'OrgTeacher': instance.orgTeacher,
      'OrgHourFrom': instance.orgHourFrom,
      'OrgHourTo': instance.orgHourTo,
      'NewClassroom': instance.newClassroom,
      'NewDate': instance.newDate?.toIso8601String(),
      'NewLessonNo': instance.newLessonNo,
      'NewLesson': instance.newLesson,
      'NewSubject': instance.newSubject,
      'NewTeacher': instance.newTeacher,
      'NewHourFrom': instance.newHourFrom,
      'NewHourTo': instance.newHourTo,
      'SubstitutionClassUrl': instance.substitutionClassUrl,
    };

Link _$LinkFromJson(Map<String, dynamic> json) => Link(
      id: json['Id'] as String,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$LinkToJson(Link instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };

Class _$ClassFromJson(Map<String, dynamic> json) => Class(
      id: json['Id'] as int,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$ClassToJson(Class instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      id: json['Id'] as String,
      name: json['Name'] as String,
      short: json['Short'] as String,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Short': instance.short,
      'Url': instance.url,
    };

Teacher _$TeacherFromJson(Map<String, dynamic> json) => Teacher(
      id: json['Id'] as String,
      firstName: json['FirstName'] as String,
      lastName: json['LastName'] as String,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
      'Id': instance.id,
      'FirstName': instance.firstName,
      'LastName': instance.lastName,
      'Url': instance.url,
    };
