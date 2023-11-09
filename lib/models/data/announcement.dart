import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/models/data/teacher.dart';

import 'package:hive/hive.dart';
part 'announcement.g.dart';

@HiveType(typeId: 21)
@JsonSerializable()
class Announcement extends Equatable {
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
  final int id;
  
  @HiveField(1)
  final String url;

  @HiveField(2)
  final bool read;

  @HiveField(3)
  final String subject;

  @HiveField(4)
  final String content;

  @HiveField(5)
  final Teacher? contact;

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  final DateTime endDate;

  @override
  List<Object> get props => [id, url, subject, content];

  factory Announcement.fromJson(Map<String, dynamic> json) => _$AnnouncementFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);
}
