import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/teacher.dart';

import 'package:hive/hive.dart';
part 'announcement.g.dart';

@HiveType(typeId: 21)
@JsonSerializable()
class Announcement extends HiveObject {
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

  @HiveField(0)
  int id;
  
  @HiveField(1)
  String url;

  @HiveField(2)
  bool read;

  @HiveField(3)
  String subject;

  @HiveField(4)
  String content;

  @HiveField(5)
  Teacher? contact;

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  DateTime endDate;

  factory Announcement.fromJson(Map<String, dynamic> json) => _$AnnouncementFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);
}
