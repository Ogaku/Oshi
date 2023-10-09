import 'package:json_annotation/json_annotation.dart';
import 'package:szkolny/models/data/classroom.dart';
import 'package:szkolny/models/data/teacher.dart';

part 'event.g.dart';

@JsonSerializable(includeIfNull: false)
class Event {
  Event(
      {required this.id,
      this.lessonNo,
      this.date,
      this.addDate,
      required this.timeFrom,
      this.timeTo,
      this.title,
      required this.content,
      required this.categoryName,
      required this.category,
      this.sender,
      this.classroom,
      this.markAsViewed,
      this.markAsDone});

  int id;
  int? lessonNo;
  DateTime? date;
  DateTime? addDate;
  DateTime timeFrom;
  DateTime? timeTo;
  String? title;
  String content;
  String categoryName;

  EventCategory category;
  Teacher? sender;
  Classroom? classroom;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Future Function()? markAsViewed;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Future Function()? markAsDone;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}

enum EventCategory {
  gathering, // Zebranie
  lecture, // Lektura
  test, // Test
  classWork, // Praca Klasowa
  semCorrection, // Poprawka
  other, // Inne
  lessonWork, // Praca na Lekcji
  shortTest, // Kartkowka
  correction, // Poprawa
  onlineLesson, // Online
  homework, // Praca domowa (horror)
  teacher, // Nieobecnosc nauczyciela
  freeDay, // Dzien wolny (opis)
  conference // Wywiadowka
}
