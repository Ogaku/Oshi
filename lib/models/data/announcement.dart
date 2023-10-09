import 'package:json_annotation/json_annotation.dart';
import 'package:szkolny/models/data/teacher.dart';

part 'announcement.g.dart';

@JsonSerializable()
class Announcement {
  Announcement({
    required this.id,
    required this.url,
    required this.read,
    required this.subject,
    required this.content,
    this.contact,
    required this.startDate,
    required this.endDate,
  });

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
