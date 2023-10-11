import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/teacher.dart';

part 'announcement.g.dart';

@JsonSerializable()
class Announcement {
  Announcement({
    this.id = -1,
    this.url = '',
    this.read = false,
    this.subject = '',
    this.content = '',
    this.contact,
    DateTime? startDate,
    DateTime? endDate,
  })  : startDate = startDate ?? DateTime(2000),
        endDate = endDate ?? DateTime(2000);

  int id;
  String url;
  bool read;
  String subject;
  String content;
  Teacher? contact;
  DateTime startDate;
  DateTime endDate;

  factory Announcement.fromJson(Map<String, dynamic> json) => _$AnnouncementFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);
}
