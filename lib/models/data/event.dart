import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/interface/cupertino/views/grades_detailed.dart';
import 'package:oshi/models/data/classroom.dart';
import 'package:oshi/models/data/messages.dart';
import 'package:oshi/models/data/teacher.dart';

import 'package:hive/hive.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
part 'event.g.dart';

@HiveType(typeId: 25)
@JsonSerializable(includeIfNull: false)
class Event extends Equatable {
  Event(
      {this.id = -1,
      this.lessonNo,
      this.date,
      this.addDate,
      DateTime? timeFrom,
      this.timeTo,
      this.title,
      this.content = '',
      this.categoryName = '',
      this.category = EventCategory.other,
      this.done = false,
      this.sender,
      this.attachments,
      this.classroom,
      bool? isOwnEvent})
      : timeFrom = timeFrom ?? DateTime(2000),
        isOwnEvent = isOwnEvent ?? false;

  Event.from(
      {Event? other,
      int? id,
      int? lessonNo,
      DateTime? date,
      DateTime? addDate,
      DateTime? timeFrom,
      DateTime? timeTo,
      String? title,
      String? content,
      String? categoryName,
      EventCategory? category,
      bool? done,
      bool? isOwnEvent,
      Teacher? sender,
      Classroom? classroom,
      List<Attachment>? attachments})
      : id = id ?? other?.id ?? -1,
        lessonNo = lessonNo ?? other?.lessonNo,
        date = date ?? other?.date,
        addDate = addDate ?? other?.addDate,
        timeFrom = timeFrom ?? other?.timeFrom ?? DateTime(2000),
        timeTo = timeTo ?? other?.timeTo,
        title = title ?? other?.title,
        content = content ?? other?.content ?? '',
        categoryName = categoryName ?? other?.categoryName ?? '',
        category = category ?? other?.category ?? EventCategory.other,
        done = done ?? other?.done ?? false,
        sender = sender ?? other?.sender,
        attachments = attachments ?? other?.attachments,
        classroom = classroom ?? other?.classroom,
        isOwnEvent = isOwnEvent ?? other?.isOwnEvent ?? false;

  @HiveField(0)
  final int id;

  @HiveField(1)
  final int? lessonNo;

  @HiveField(2)
  final DateTime? date;

  @HiveField(3)
  final DateTime? addDate;

  @HiveField(4)
  final DateTime timeFrom;

  @HiveField(5)
  final DateTime? timeTo;

  @HiveField(6)
  final String? title;

  @HiveField(7)
  final String content;

  @HiveField(8)
  final String categoryName;

  @HiveField(9)
  final bool done; // For homeworks

  @HiveField(10)
  final EventCategory category;

  @HiveField(11)
  final Teacher? sender;

  @HiveField(12)
  final Classroom? classroom;

  // Set to null for no attachments
  @HiveField(13)
  final List<Attachment>? attachments; // For homeworks

  @HiveField(14)
  final bool isOwnEvent;

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get _categoryName => categoryName.isNotEmpty ? categoryName : category.asString();

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get titleString => "${_categoryName.capitalize()}${(title ?? content).isNotEmpty ? ':' : ''} ${title ?? content}";

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get subtitleString => (title != null && title != content) ? content : '';

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get locationString =>
      (lessonNo != null ? 'Lesson no. $lessonNo • ' : '') +
      (isOwnEvent ? Share.session.data.student.account.name : (sender?.name ?? ''));

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get locationTypeString =>
      (lessonNo != null ? 'Lesson no. $lessonNo • ' : '') +
      _categoryName +
      (classroom != null ? ' • ${classroom!.name}' : '') +
      (sender != null ? ' • Added by ${sender!.name}' : '');

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get addedByString => (sender != null ? 'Added by ${sender!.name}' : '');

  @override
  List<Object> get props => [id, timeFrom, content, categoryName, done, category];

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}

@HiveType(typeId: 101)
enum EventCategory {
  @HiveField(0)
  gathering, // Zebranie
  @HiveField(1)
  lecture, // Lektura
  @HiveField(2)
  test, // Test
  @HiveField(3)
  classWork, // Praca Klasowa
  @HiveField(4)
  semCorrection, // Poprawka
  @HiveField(5)
  other, // Inne
  @HiveField(6)
  lessonWork, // Praca na Lekcji
  @HiveField(7)
  shortTest, // Kartkowka
  @HiveField(8)
  correction, // Poprawa
  @HiveField(9)
  onlineLesson, // Online
  @HiveField(10)
  homework, // Praca domowa (horror)
  @HiveField(11)
  teacher, // Nieobecnosc nauczyciela
  @HiveField(12)
  freeDay, // Dzien wolny (opis)
  @HiveField(13)
  conference, // Wywiadowka
  @HiveField(14)
  admin // Admin events
}

extension EventCategoryExtension on EventCategory {
  String asString() => '/Enums/EventCategory/$name'.localized;
}
