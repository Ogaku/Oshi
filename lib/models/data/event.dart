import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/interface/cupertino/views/grades_detailed.dart';
import 'package:ogaku/models/data/classroom.dart';
import 'package:ogaku/models/data/teacher.dart';

import 'package:hive/hive.dart';
part 'event.g.dart';

@HiveType(typeId: 25)
@JsonSerializable(includeIfNull: false)
class Event extends HiveObject {
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
      this.classroom})
      : timeFrom = timeFrom ?? DateTime(2000);

  @HiveField(0)
  int id;

  @HiveField(1)
  int? lessonNo;

  @HiveField(2)
  DateTime? date;

  @HiveField(3)
  DateTime? addDate;

  @HiveField(4)
  DateTime timeFrom;

  @HiveField(5)
  DateTime? timeTo;

  @HiveField(6)
  String? title;

  @HiveField(7)
  String content;

  @HiveField(8)
  String categoryName;

  @HiveField(9)
  bool done; // For homeworks

  @HiveField(10)
  EventCategory category;

  @HiveField(11)
  Teacher? sender;

  @HiveField(12)
  Classroom? classroom;

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get titleString => "${categoryName.capitalize()}${(title ?? content).isNotEmpty ? ':' : ''} ${title ?? content}";

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get subtitleString => (title != null && title != content) ? content : '';

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get locationString => (lessonNo != null ? 'Lesson no. $lessonNo • ' : '') + (sender?.name ?? '');

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
  conference // Wywiadowka
}
