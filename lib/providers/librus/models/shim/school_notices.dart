import 'package:json_annotation/json_annotation.dart';

part 'school_notices.g.dart';

@JsonSerializable()
class SchoolNotices {
  SchoolNotices({
    required this.schoolNotices,
  });

  @JsonKey(name: 'SchoolNotices')
  final List<SchoolNotice>? schoolNotices;

  factory SchoolNotices.fromJson(Map<String, dynamic> json) => _$SchoolNoticesFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolNoticesToJson(this);
}

@JsonSerializable()
class SchoolNotice {
  SchoolNotice({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.subject,
    required this.content,
    required this.addedBy,
    required this.creationDate,
    required this.wasRead,
  });

  @JsonKey(name: 'Id')
  final String id;

  @JsonKey(name: 'StartDate')
  final DateTime? startDate;

  @JsonKey(name: 'EndDate')
  final DateTime? endDate;

  @JsonKey(name: 'Subject')
  final String subject;

  @JsonKey(name: 'Content')
  final String content;

  @JsonKey(name: 'AddedBy')
  final AddedBy? addedBy;

  @JsonKey(name: 'CreationDate')
  final DateTime? creationDate;

  @JsonKey(name: 'WasRead')
  final bool wasRead;

  factory SchoolNotice.fromJson(Map<String, dynamic> json) => _$SchoolNoticeFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolNoticeToJson(this);
}

@JsonSerializable()
class AddedBy {
  AddedBy({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory AddedBy.fromJson(Map<String, dynamic> json) => _$AddedByFromJson(json);

  Map<String, dynamic> toJson() => _$AddedByToJson(this);
}
