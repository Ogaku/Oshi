import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/classroom.dart';
import 'package:ogaku/models/data/teacher.dart';

part 'event.g.dart';

@JsonSerializable(includeIfNull: false)
class Event {
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
      this.classroom,
      this.markAsViewed,
      this.markAsDone})
      : timeFrom = timeFrom ?? DateTime(2000);

  int id;
  int? lessonNo;
  DateTime? date;
  DateTime? addDate;
  DateTime timeFrom;
  DateTime? timeTo;
  String? title;
  String content;
  String categoryName;
  bool done; // For homeworks

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
