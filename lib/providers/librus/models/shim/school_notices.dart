import 'package:json_annotation/json_annotation.dart';

part 'school_notices.g.dart';

@JsonSerializable()
class SchoolNotices {
  SchoolNotices({
    required this.schoolNotices,
  });

  @JsonKey(name: 'SchoolNotices', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: '')
  final String id;

  @JsonKey(name: 'StartDate', defaultValue: null)
  final DateTime? startDate;

  @JsonKey(name: 'EndDate', defaultValue: null)
  final DateTime? endDate;

  @JsonKey(name: 'Subject', defaultValue: '')
  final String subject;

  @JsonKey(name: 'Content', defaultValue: '')
  final String content;

  @JsonKey(name: 'AddedBy', defaultValue: null)
  final AddedBy? addedBy;

  @JsonKey(name: 'CreationDate', defaultValue: null)
  final DateTime? creationDate;

  @JsonKey(name: 'WasRead', defaultValue: false)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory AddedBy.fromJson(Map<String, dynamic> json) => _$AddedByFromJson(json);

  Map<String, dynamic> toJson() => _$AddedByToJson(this);
}
