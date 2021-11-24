import 'package:json_annotation/json_annotation.dart';
part 'data.g.dart';

@JsonSerializable()
class Access {
  String access_token;
  String token_type;
  String expires_in;
  String grant_type;

  Access({
    required this.access_token,
    required this.token_type,
    required this.expires_in,
    required this.grant_type,
  });

  factory Access.fromJson(Map<String, dynamic> json) => _$AccessFromJson(json);
  Map<String, dynamic> toJson() => _$AccessToJson(this);
}

@JsonSerializable()
class ResponseData {
  int code;
  dynamic meta;
  List<dynamic> data;
  ResponseData({
    required this.code,
    required this.meta,
    required this.data,
  });
  factory ResponseData.fromJson(Map<String, dynamic> json) =>
      _$ResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _$ResponseDataToJson(this);
}

// @JsonSerializable()
// class User2 {
//   int id;
//   String name;
//   String email;
//   String gender;
//   String status;
//   String created_at;
//   String updated_at;

//   User2({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.gender,
//     required this.status,
//     required this.created_at,
//     required this.updated_at,
//   });

//   factory User2.fromJson(Map<String, dynamic> json) => _$User2FromJson(json);
//   Map<String, dynamic> toJson() => _$User2ToJson(this);
// }

// @JsonSerializable()
// class ResponseData {
//   int code;
//   dynamic meta;
//   List<dynamic> data;
//   ResponseData({required this.code, required this.meta, required this.data});
//   factory ResponseData.fromJson(Map<String, dynamic> json) =>
//       _$ResponseDataFromJson(json);
//   Map<String, dynamic> toJson() => _$ResponseDataToJson(this);
// }
